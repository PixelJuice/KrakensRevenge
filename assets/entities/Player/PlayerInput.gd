extends Node3D;

class_name PlayerInput

@export var MAX_SPEED = 0.3;
@export var ACCELERATION = 0.15;
@export var DECELERATION = 0.05;
@export var BREAK = 0.25;
var currentVelocity := Vector2.ZERO
var playerArea
var boosted = false
var boost : float = 100

signal boost_value(value)

func _ready() -> void:
	playerArea = get_node("Area3D")

func _process(delta: float) -> void:
	var acceleration = _boost(delta)
	_eat()
	var input_direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	if input_direction != Vector2.ZERO:
		var targetVelocity = input_direction * MAX_SPEED
		var velocityChange = targetVelocity - currentVelocity
		if velocityChange.length() > 0:
			currentVelocity += velocityChange.normalized() * acceleration * delta
	else:
		currentVelocity = currentVelocity.move_toward(Vector2.ZERO, DECELERATION * delta)

	if input_direction.dot(currentVelocity.normalized()) < 0:
		currentVelocity = currentVelocity.move_toward(Vector2.ZERO, BREAK * delta)

	position.x += currentVelocity.x
	position.z += currentVelocity.y


func on_died() :
	set_process(false)

func _boost(delta: float) -> float:
	if Input.is_action_just_pressed("boost") && boost > 33 :
		boosted = true
		boost -= 33
		boost_value.emit(boost)
		return ACCELERATION * 100.
	else :
		boost += 20 * delta
		boost = clampf(boost, 0, 100)
		boost_value.emit(boost)
		return ACCELERATION

func _eat() :
	if Input.is_action_just_pressed("ui_accept") :
		for body in playerArea.get_overlapping_bodies():
			body.GetEaten.emit()
