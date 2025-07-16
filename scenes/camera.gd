extends Node3D

@export var player: Node3D

@export var zoom_speed: float = 2.0
@export var min_fov: float = 30.0
@export var max_fov: float = 90.0
@export var camera: Camera3D

@onready var animationPlayer = $AnimationPlayer

var initial_offset: Vector3

func _ready():
	animationPlayer.animation_finished.connect(_on_animation_finished)
	if player:
		initial_offset = global_transform.origin - player.global_transform.origin

func _process(delta: float) -> void:
	if player:
		var target_position = player.global_transform.origin + initial_offset
		# Only update X and Z; keep Y unchanged
		global_transform.origin.x = target_position.x
		global_transform.origin.z = target_position.z


func zoom_in():
	animationPlayer.play("zoom")

func zoom_out():
	animationPlayer.play("unzoom")

func _on_animation_finished(anim_name: String) -> void:
	pass
