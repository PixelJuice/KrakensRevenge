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
@export var difficulty_increase: float = .1
var _predatorRef

# Rule weights
@export var cohesionWeight: float = .1
@export var targetWeight: float = .5
@export var separationWeight: float = 120
@export var alignmentWeight: float = .1

@export var predatorWeight: float = 100
var lastPredatorValue : float = 0
var predator_cooldown: float = 0.0
var _boids = []
var ships_eaten = 0

signal ship_eaten(value: int)
	
func _ready():
	pause()

func _start_game():
	randomize()
	ships_eaten = 0
	set_physics_process(true)
	_predatorRef = get_node(predator)
	for i in range(numberOfBoids):
		spawn()

func spawn():
	var instance = boidScene.instantiate()
	instance.maxEscapeVelocity += ships_eaten * difficulty_increase
	instance.minEscapeVelocity += ships_eaten * difficulty_increase
	instance.maxVelocity += ships_eaten * difficulty_increase
	instance.minVelocity += ships_eaten * difficulty_increase
	instance.set_values()
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
	ships_eaten = 0
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

func on_predator_scares(value : float) -> void:
	predator_cooldown = value

func remove_instance(boid):
	ships_eaten += 1
	emit_signal("ship_eaten", ships_eaten)
	_boids.erase(boid)
	spawn()

func _physics_process(delta):
	_detectNeighbors()
	_target()
	#_cohesion()
	_separation()
	_alignment()
	_escapePredator(delta)
	too_far_from_predator()

func too_far_from_predator() -> void:
	for boid in _boids:
		var dist = boid.get_position().distance_to(_predatorRef.get_position())
		if dist > 250:
			boid.set_position(get_pos_outside_camera_view(get_random_direction()))
			boid.target = get_pos_on_other_side(boid)
			boid.acceleration = Vector3.ZERO
			boid.velocity = Vector3.ZERO
			boid.escaping = false
		elif dist > 130	:
			boid.outside_view = true
			boid.target = get_pos_on_other_side(boid)
		else:
			boid.outside_view = false


func _detectNeighbors():
	for boid in _boids:
		boid.neighbors.clear()
		boid.neighborsDistances.clear()

	for i in range(_boids.size()):
		for j in range(i+1, _boids.size()):
			var distance = _boids[i].get_position().distance_to(_boids[j].get_position())
			if (distance <= visualRange):
				_boids[i].neighbors.append(_boids[j])
				_boids[j].neighbors.append(_boids[i])
				_boids[i].neighborsDistances.append(distance)
				_boids[j].neighborsDistances.append(distance)

func _target():
	for boid in _boids:
		if boid.get_position().distance_to(boid.target) < 20 :
			boid.target = get_pos_on_other_side(boid)
		var direction = boid.target - boid.get_position()
		boid.acceleration += direction * targetWeight
		boid.acceleration.y = 0

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
		# Only process predator escape if cooldown is active
	if predator_cooldown > 0:
		for boid in _boids:
			var dist = boid.get_position().distance_to(_predatorRef.get_position())

		# Check if the boid is within the predator's range
			if dist < predatorMinDist:
				# Calculate the escape direction
				var dir = (boid.get_position() - _predatorRef.get_position()).normalized()

				# Scale acceleration based on distance (closer = stronger acceleration)
				var distance_factor = 1.0 - (dist / predatorMinDist) # Closer = higher factor
				var scaled_acceleration = predatorWeight * distance_factor
				# Apply acceleration to the boid
				boid.acceleration += dir * scaled_acceleration
				boid.acceleration.y = 0

				# Determine if the boid is escaping
				boid.escaping = scaled_acceleration > escapeTreshold
			else:
				boid.escaping = false
	predator_cooldown = max(predator_cooldown, 0)


func pause() :
	for boid in _boids:
		boid.set_physics_process(false)
	set_physics_process(false)


func _on_start_game_countdown_started() -> void:
	pass # Replace with function body.
