class_name Player
extends Sprite3D;

@export var MAX_SPEED : float  = 0.5;
@export var MAX_SPEED_BOOST : float = 1;
@export var BOOST_COST : float = 10.;
@export var ACCELERATION : float = 0.2;
@export var BOOST_ACCELERATION : float = 20.;
@export var DECELERATION : float = 0.05;
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
@onready var tail = $tail
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
	var acceleration = _boost(delta)
	_eat()
	input_direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	var current_max_speed = MAX_SPEED
	if boosted:
		current_max_speed = MAX_SPEED_BOOST

	if input_direction != Vector2.ZERO:
		var targetVelocity = input_direction * current_max_speed
		var velocityChange = targetVelocity - currentVelocity
		if velocityChange.length() > 0:
			currentVelocity += velocityChange.normalized() * acceleration * delta
	else:
		currentVelocity = currentVelocity.move_toward(Vector2.ZERO, DECELERATION * delta)

	if currentVelocity.length() > 0 and input_direction != Vector2.ZERO:
		if input_direction.dot(currentVelocity.normalized()) < -0.5:
			currentVelocity = currentVelocity.move_toward(Vector2.ZERO, BREAK * delta)
			#print("break", currentVelocity)

	update_health(delta, currentVelocity)
	position.x += currentVelocity.x
	position.z += currentVelocity.y
	#rotation.x = -75. * PI / 180.
	#sorting_offset = position.z -1
	if currentVelocity.length() > 0:
		scare.emit(PREDATOR_COOLDOWN)
		update_tail(delta)

func update_tail(_delta: float) -> void:
	if currentVelocity.length() > 0:
		var velocity_factor = currentVelocity.length() / MAX_SPEED
		velocity_factor = clampf(velocity_factor, 0.0, 1.0)
		var offset_tail = 4.0 * velocity_factor  # Offset increases with velocity
		tail.rotation.y = -currentVelocity.angle() + PI / 2 # Rotate to point opposite to velocity
		tail.position.z = -offset_tail * sin(currentVelocity.angle())  # Small offset from center
		tail.position.x = -offset_tail * cos(currentVelocity.angle())  # Small offset from center
		tail.scale.x = lerp(.0, 2.0, velocity_factor)  # Scale based on velocity
		tail.scale.z = lerp(.0, 5.0, velocity_factor)
	else:
		tail.rotation.y = 0
		tail.position.x = 0
		tail.position.z = 0
		tail.scale.z = 0.0
		tail.scale.x = 0.0


func on_died() :
	animationPlayer.play("hiding")
	set_process(false)



func update_health(delta: float, velocity: Vector2) -> void:
	var health_drain = HEALTH_DRAIN_WAITING
	if velocity.length() > 0:
		health_drain = HEALTH_DRAIN_MOVING

	health -= delta * health_drain
	health = clampf(health, 0, MAX_HEALTH)
	health_value.emit(health)
	if health <= 0:
		print("Player died")
		died.emit()
		on_died()


func _boost(delta: float) -> float:
	if Input.is_action_just_pressed("boost") && boost > BOOST_COST :
		boosted = true
		boost -= BOOST_COST
		boost_value.emit(boost)
		boost_timer = 0.5
		return BOOST_ACCELERATION
	elif boosted:
		boost_timer -= delta
		if boost_timer <= 0:
			boosted = false
			boost_timer = 0.0
	else :
		boost += 20 * delta
		boost = clampf(boost, 0, 100)
		boost_value.emit(boost)
	return ACCELERATION

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
