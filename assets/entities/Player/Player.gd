class_name Player
extends Sprite3D;

@export var MAX_SPEED : float  = 0.5;
@export var MAX_SPEED_BOOST : float = 1;
@export var BOOST_COST : float = 10.;
@export var BOOST_COOLDOWN : float = 1.;
@export var BOOST_RECHARGE : float = 10.;
@export var ACCELERATION : float = 2.0;
@export var BOOST_ACCELERATION : float = 2.;
@export var DECELERATION : float = 1.;
@export var BREAK : float = 0.25;
@export var MAX_HEALTH : float = 100.0;
@export var HEALTH_PER_EAT : float = 10.0;
@export var HEALTH_DRAIN_MOVING : float = 100.0;
@export var HEALTH_DRAIN_WAITING : float = 0.0;
@export var PREDATOR_COOLDOWN: float = 3.0
@export var PREDATOR_COOLDOWN_EATING: float = 5.0
@export var MAX_BOOST : float = 100.0;
@onready var animationPlayer = $AnimationPlayer
@onready var playerArea = $Area3D
@onready var shadow2 = $Shadow2
@onready var shadow3 = $Shadow3
var speed = 0.01
var currentVelocity := Vector2.ZERO
var input_direction : Vector2 = Vector2.ZERO
var boosted : bool = false
var boost : float = MAX_HEALTH
var health : float = MAX_BOOST
var boost_timer : float = 0.0


signal boost_value(value)
signal health_value(value)
signal max_boost(value)
signal max_health(value)
signal died
signal eating
signal done_eating
signal scare

func _ready() -> void:
	animationPlayer.play("hiding")
	animationPlayer.animation_finished.connect(_on_animation_finished)
	pause()

func start() -> void:
	set_process(true)
	animationPlayer.play("appear")
	print("Player started")
	currentVelocity = Vector2.ZERO
	boosted = false
	boost = MAX_BOOST
	health = MAX_HEALTH
	max_boost.emit(MAX_BOOST)
	max_health.emit(MAX_HEALTH)
	boost_value.emit(boost)
	health_value.emit(health)

func _process(delta: float) -> void:
	_eat()
	_boost(delta)
	input_direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	var current_max_speed = MAX_SPEED
	if boosted:
		current_max_speed = MAX_SPEED_BOOST

	if boosted:
		speed = clamp(speed + delta * BOOST_ACCELERATION, 0.0, 100.)  # Accelerate faster when boosted
	else:
		speed = clamp(speed + delta * ACCELERATION, 0.0, 100) 
		
	if input_direction != Vector2.ZERO:
		var targetVelocity = input_direction * current_max_speed
		currentVelocity = currentVelocity.lerp(targetVelocity, speed * delta)  # Smoothly interpolate towards target velocity

	else:
		currentVelocity = currentVelocity.lerp(Vector2.ZERO, DECELERATION * delta)
		speed = clamp(speed - delta * BREAK, 0.0, 1.0)  # Smoothly decrease speed when not moving

	if currentVelocity.length() > 0 and input_direction != Vector2.ZERO:
		if input_direction.dot(currentVelocity.normalized()) < -0.5:
			currentVelocity = currentVelocity.move_toward(Vector2.ZERO, BREAK * delta)
			#print("break", currentVelocity)

	update_health(delta, currentVelocity)
	position.x += currentVelocity.x
	position.z += currentVelocity.y
	input_direction = Vector2.ZERO
	#rotation.x = -75. * PI / 180.
	#sorting_offset = position.z -1
	if currentVelocity.length() > .1:
		scare.emit(PREDATOR_COOLDOWN)
	update_tail(delta)

func update_tail(_delta: float) -> void:
	if currentVelocity.length() > 0:
		var velocity_factor = currentVelocity.length() / MAX_SPEED
		velocity_factor = clampf(velocity_factor, 0.0, 1.0)

		var shadow_offset = 3.0 * velocity_factor
		var shadow_pos: Vector3 = Vector3.ZERO;
		shadow_pos.z = -shadow_offset * sin(currentVelocity.angle())
		shadow_pos.x = -shadow_offset * cos(currentVelocity.angle())
		shadow2.position = lerp(shadow2.position, shadow_pos, .01)

		shadow_offset = 6.0 * velocity_factor
		shadow_pos = Vector3.ZERO;
		shadow_pos.z = -shadow_offset * sin(currentVelocity.angle())
		shadow_pos.x = -shadow_offset * cos(currentVelocity.angle())
		shadow3.position = lerp(shadow3.position, shadow_pos, .01)# Small offset from center # Small offset from center  # Small offset from center # Small offset from center  # Small offset from center
	else:
		shadow2.position = Vector3.ZERO
		shadow3.position = Vector3.ZERO



func on_died() :
	animationPlayer.play("hiding")
	set_process(false)



func update_health(delta: float, velocity: Vector2) -> void:
	var health_drain = HEALTH_DRAIN_WAITING
	if velocity.length() > 0:
		health_drain = HEALTH_DRAIN_MOVING * velocity.length() / MAX_SPEED

	health -= delta * health_drain
	health = clampf(health, 0, MAX_HEALTH)
	health_value.emit(health)
	if health <= 0:
		print("Player died")
		died.emit()
		on_died()


func _boost(delta: float) -> void:
	if Input.is_action_just_pressed("boost") && boost > BOOST_COST :
		boosted = true
		boost -= BOOST_COST
		boost_value.emit(boost)
		boost_timer = BOOST_COOLDOWN
	elif boosted:
		boost_timer -= delta
		if boost_timer <= 0:
			boosted = false
			boost_timer = 0.0
	else :
		boost += BOOST_RECHARGE * delta
		boost = clampf(boost, 0, MAX_BOOST)
		boost_value.emit(boost)

func _eat() :
	if Input.is_action_just_pressed("eat") and playerArea:
		print("Eating")
		for body in playerArea.get_overlapping_bodies():
			scare.emit(PREDATOR_COOLDOWN_EATING)
			animationPlayer.play("eat_01")
			health +=  HEALTH_PER_EAT
			health = clampf(health, 0, MAX_HEALTH)
			health_value.emit(health)
			currentVelocity = Vector2.ZERO
			set_process(false)
			body.GetEaten.emit()
			eating.emit()


func pause() -> void:
	set_process(false)

func unpause() -> void:
	animationPlayer.play("swim")
	set_process(true)


func _on_animation_finished(anim_name: String):
	if anim_name == "eat_01":
		animationPlayer.play("appear")
		done_eating.emit()
		set_process(true)
	elif anim_name == "appear":
		animationPlayer.play("swim")
