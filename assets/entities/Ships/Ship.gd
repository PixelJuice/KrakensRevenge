extends Sprite3D

class_name Boid

@onready var camera = get_viewport().get_camera_3d()
@onready var animationPlayer = $AnimationPlayer
@onready var boat = $boat

@export var minVelocity: float = 5
@export var maxVelocity: float = 10


@export var minEscapeVelocity: float = 12
@export var maxEscapeVelocity: float = 30


@export var maxAcceleration: float = 80
@export var minAcceleration: float = 20

var velocity := Vector3.ZERO
var acceleration := Vector3.ZERO

var neighbors := []
var neighborsDistances := []
var timeOutOfBorders := 0.0
var target := Vector3.ZERO
var escaping = false

var manager

func set_values():
	velocity = Vector3(randf_range(-maxVelocity + 5.0, maxVelocity -5.0), 0, randf_range(-maxVelocity + 5.0, maxVelocity -5.0))
	maxVelocity = randf_range(minVelocity, maxVelocity)
	maxEscapeVelocity = randf_range(minEscapeVelocity, maxEscapeVelocity)
	maxAcceleration = randf_range(minAcceleration, maxAcceleration)
	rotation.x = -75. * PI / 180.

func _process(delta):
	velocity += acceleration.limit_length(maxAcceleration * delta)
	if escaping :
		velocity = velocity.limit_length(maxEscapeVelocity)
	else :
		velocity = velocity.limit_length(maxVelocity)
	acceleration.x = 0
	acceleration.y = 0
	acceleration.z = 0

	position.x += velocity.x * delta
	position.z += velocity.z * delta
	sorting_offset = position.z -1
	updateAnimation()
	position.y = 1.9
	rotation.x = -75. * PI / 180.



func _get_eaten() -> void:
	manager.remove_instance(self)
	queue_free()

func updateAnimation() -> void:
	if abs(velocity.x) > abs(velocity.z):
		if velocity.x > 0:
			$AnimationPlayer.play("right")
		else:
			$AnimationPlayer.play("left")
	else:
		if velocity.z > 0:
			$AnimationPlayer.play("down")
		else:
			$AnimationPlayer.play("up")
	pass
