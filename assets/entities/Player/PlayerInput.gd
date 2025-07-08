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

	
func _process(delta: float):
	_boost(delta)
	_eat()
	if Input.is_action_pressed("ui_left"):
		var acceleration = ACCELERATION;
		if currentVelocity.x > 0:
			acceleration += BREAK
		currentVelocity.x -= acceleration * delta;
	elif Input.is_action_pressed("ui_right"):
		var acceleration = ACCELERATION
		if currentVelocity.x < 0:
			acceleration += BREAK
		currentVelocity.x += acceleration * delta;
	else:
		if currentVelocity.x > 0:
			currentVelocity.x -= DECELERATION * delta;
		else:
			currentVelocity.x += DECELERATION * delta;
	if Input.is_action_pressed("ui_up"):
		var acceleration = ACCELERATION;
		if currentVelocity.y > 0:
			acceleration += BREAK
		currentVelocity.y -= acceleration * delta;
	elif Input.is_action_pressed("ui_down"):
		var acceleration = ACCELERATION;
		if currentVelocity.y < 0:
			acceleration += BREAK
		currentVelocity.y += acceleration * delta;
	else:
		if currentVelocity.y > 0:
			currentVelocity.y -= DECELERATION * delta;
		else:
			currentVelocity.y += DECELERATION * delta;
			
	if !boosted :
		currentVelocity.x = clampf(currentVelocity.x, -MAX_SPEED, MAX_SPEED)
		currentVelocity.y = clampf(currentVelocity.y, -MAX_SPEED, MAX_SPEED)
	else :
		print(currentVelocity.length())
		print(Vector2(MAX_SPEED, MAX_SPEED))
		if abs(currentVelocity) > Vector2(MAX_SPEED, MAX_SPEED): 
			currentVelocity -= currentVelocity * -1
		else :
			boosted = false
	#print(currentVelocity)
	position.x += currentVelocity.x 
	position.z += currentVelocity.y 


func on_died() :
	set_process(false)

func _boost(delta: float) :
	if Input.is_action_just_pressed("boost") && boost > 33 :
		boosted = true
		currentVelocity += currentVelocity*0.5
		boost -= 33
		boost_value.emit(boost)
	else :
		boost += 20 * delta
		boost = clampf(boost, 0, 100)
		boost_value.emit(boost)

func _eat() :
	if Input.is_action_just_pressed("ui_accept") :
		for body in playerArea.get_overlapping_bodies():
			body.GetEaten.emit()
