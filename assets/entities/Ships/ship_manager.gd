extends Node3D

# General configuration
@export var boidScene: PackedScene
@export var numberOfBoids: int = 100
@export var visualRange: float = 60
@export var separationDistance: float = 50
@export var predator: NodePath
@export var predatorMinDist: float = 40
@export var escapeTreshold: = 60
var _predatorRef

# Rule weights
@export var cohesionWeight: float = .1
@export var targetWeight: float = .3
@export var separationWeight: float = 80
@export var alignmentWeight: float = .1

@export var predatorWeight: float = 200
@export var PredatorValueFade: float = 8
var lastPredatorValue : float = 0

var _boids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	_predatorRef = get_node(predator)
	for i in range(numberOfBoids):
		spawn()

func spawn():
	var instance = boidScene.instantiate()
	instance.manager = self
	_boids.append(instance)
	var start_pos = get_pos_around_predator()
	instance.target = get_pos_around_predator()
	instance.set_position(Vector3(start_pos.x, 0, start_pos.z))
	add_child(instance)

func remove_instance(boid):
	_boids.erase(boid)
	spawn()

func get_pos_around_predator():
	var p_pos = _predatorRef.get_position()
	var target : Vector3
	target.x = p_pos.x + randf_range(-200, 200)
	target.z = p_pos.z + randf_range(-200, 200)
	target.y = 0
	return target
	
func get_pos_on_other_side(pos):
	var p_pos = _predatorRef.get_position()
	var dir = pos.direction_to(p_pos)
	var dist = pos.distance_to(p_pos)
	var target : Vector3
	target = dir * randf_range(dist, 200 + dist)
	#target.z = dir.z * randf_range(dist, 200 + dist)
	target.y = 0
	if( p_pos.distance_to(target) < 20.):
		target = get_pos_on_other_side(pos);
	return target

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
			_boids[i].target = get_pos_on_other_side(_boids[i].get_position())
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
	for boid in _boids:
		var dist = boid.get_position().distance_to(_predatorRef.get_position())
		if (dist < predatorMinDist):
			var dir = (boid.get_position() - _predatorRef.get_position()).normalized()
			var multiplier = sqrt(1 - (dist / predatorMinDist))
			var playerVelocity = abs(get_node("../Player").currentVelocity)
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


func on_died() :
	for boid in _boids:
		boid.set_process(false)
	set_process(false)
