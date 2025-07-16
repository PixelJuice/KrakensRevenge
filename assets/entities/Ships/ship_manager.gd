class_name ShipManager
extends Node3D

# General configuration
@export var boidScene: PackedScene
@export var numberOfBoids: int = 100
@export var visualRange: float = 90
@export var separationDistance: float = 60
@export var predator: NodePath
@export var predatorMinDist: float = 40
@export var escapeTreshold: = 10
var _predatorRef

# Rule weights
@export var cohesionWeight: float = .1
@export var targetWeight: float = .5
@export var separationWeight: float = 120
@export var alignmentWeight: float = .1

@export var predatorWeight: float = 100
@export var PredatorValueFade: float = 100
@export var PREDATOR_COOLDOWN: float = 3.0
var lastPredatorValue : float = 0
var predator_cooldown: float = 0.0
var _boids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	_predatorRef = get_node(predator)
	for i in range(numberOfBoids):
		spawn()
	pause()

func _start_game():
	# This function can be called to start the game, e.g. after a player has died
	# or when the game is initialized.
	for boid in _boids:
		boid.set_process(true)
	set_process(true)

func spawn():
	var instance = boidScene.instantiate()
	instance.manager = self
	_boids.append(instance)
	var start_pos = get_pos_outside_camera_view(get_random_direction())
	instance.set_position(start_pos)
	instance.target = get_pos_on_other_side(instance)
	#instance.scale = Vector3(.12, .12, .12)
	add_child(instance)

func player_died():
	for boid in _boids:
		boid.queue_free()
	_boids.clear()
	pause()

func get_pos_on_other_side(boid : Sprite3D) -> Vector3:
	return get_pos_outside_camera_view(get_direction_to_predator(boid))

func get_random_direction() -> Vector3:
	var random_angle = randf_range(0, TAU) # TAU is 2 * PI
	return Vector3(cos(random_angle), 0, sin(random_angle)).normalized()

func get_direction_to_predator(boid : Sprite3D) -> Vector3:
	var p_pos = _predatorRef.get_position()
	var boid_pos = boid.get_position()
	var dir = boid_pos.direction_to(p_pos)

	return Vector3(dir.x, 0, dir.z).normalized()

func get_pos_outside_camera_view(dir : Vector3) -> Vector3:
	var p_pos = _predatorRef.get_position()
	var offset_distance = randf_range(130, 200)
	var pos = p_pos + dir * offset_distance
	pos.y = 0
	return pos

func remove_instance(boid):
	_boids.erase(boid)
	spawn()

func _process(delta):
	_detectNeighbors()
	_target()
	_cohesion()
	_separation()
	_alignment()
	#_borders(delta)
	_escapePredator(delta)

func _detectNeighbors():
	for i in range(_boids.size()):
		_boids[i].neighbors.clear()
		_boids[i].neighborsDistances.clear()

	for i in range(_boids.size()):
		for j in range(i+1, _boids.size()):
			var distance = _boids[i].get_position().distance_to(_boids[j].get_position())
			if (distance <= visualRange):
				_boids[i].neighbors.append(_boids[j])
				_boids[j].neighbors.append(_boids[i])
				_boids[i].neighborsDistances.append(distance)
				_boids[j].neighborsDistances.append(distance)

func _target():
	for i in range(_boids.size()):
		if _boids[i].get_position().distance_to(_boids[i].target) < 20 :
			_boids[i].target = get_pos_on_other_side(_boids[i])
		var direction = _boids[i].target - _boids[i].get_position()
		_boids[i].acceleration += direction * targetWeight
		_boids[i].acceleration.y = 0

func _cohesion():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors

		if (neighbors.is_empty()):
			continue;

		var averagePos = Vector3(0, 0, 0)
		for closeBoid in neighbors:
			averagePos += closeBoid.get_position()
		averagePos /= neighbors.size()

		var direction = averagePos - _boids[i].get_position()
		_boids[i].acceleration += direction * cohesionWeight
		_boids[i].acceleration.y = 0

func _separation():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		var distances = _boids[i].neighborsDistances

		if (neighbors.is_empty()):
			continue;

		for j in range(neighbors.size()):
			if (distances[j] >= separationDistance):
				continue

			var distMultiplier = 1 - (distances[j] / separationDistance)
			var direction = _boids[i].get_position() - neighbors[j].get_position()
			direction = direction.normalized()
			_boids[i].acceleration += direction * distMultiplier * separationWeight
			_boids[i].acceleration.y = 0

func _alignment():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors

		if (neighbors.is_empty()):
			continue;

		var averageVel = Vector3(0, 0, 0)
		for j in range(neighbors.size()):
			averageVel += neighbors[j].velocity
		averageVel /= neighbors.size()

		_boids[i].acceleration += averageVel * alignmentWeight
		_boids[i].acceleration.y = 0

func _escapePredator(delta):
	predator_cooldown -= delta

	var playerVelocity = abs(get_node("../Player").input_direction)
	if playerVelocity.length() > 0:
		predator_cooldown = PREDATOR_COOLDOWN
	if predator_cooldown > 0:
		for boid in _boids:
			var dist = boid.get_position().distance_to(_predatorRef.get_position())
			if (dist < predatorMinDist):
				var dir = (boid.get_position() - _predatorRef.get_position()).normalized()
				var multiplier = sqrt(1 - (dist / predatorMinDist))
				var pw = (predatorWeight * (max(playerVelocity.x, playerVelocity.y ) * 5))
				if pw < lastPredatorValue :
					pw = lastPredatorValue - (PredatorValueFade * delta)
				if pw > escapeTreshold :
					boid.escaping = true
				else :
					boid.escaping = false
				boid.acceleration += dir * multiplier * pw
				boid.acceleration.y = 0
				lastPredatorValue = pw


func pause() :
	for boid in _boids:
		boid.set_process(false)
	set_process(false)
