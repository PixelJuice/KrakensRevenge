class_name Player
extends Node3D;

@export var MAX_SPEED : float  = 0.5;
@export var MAX_SPEED_BOOST : float = 1.5;
@export var BOOST_COST : float = 10.;
@export var ACCELERATION : float = 0.2;
@export var BOOST_ACCELERATION : float = 20.;
@export var DECELERATION : float = 0.05;
@export var BREAK : float = 0.25;
var currentVelocity := Vector2.ZERO
var input_direction : Vector2 = Vector2.ZERO
var playerArea : Node3D
var boosted : bool = false
var boost : float = 100
var health : float = 100.0
var boost_timer : float = 0.0


signal boost_value(value)
signal health_value(value)
signal died

func _ready() -> void:
	playerArea = get_node("%Area3D")

	#pause()

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

	update_health(delta, input_direction)
	position.x += currentVelocity.x
	position.z += currentVelocity.y


func on_died() :
	set_process(false)

func update_health(delta: float, direction: Vector2) -> void:
	if direction.length() > 0:
		pass
		#health.value -= 500 * delta
	else:
		pass


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
	if Input.is_action_just_pressed("ui_accept") :
		for body in playerArea.get_overlapping_bodies():
			body.GetEaten.emit()

func pause() -> void:
	set_process(false)
