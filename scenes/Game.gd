class_name Game
extends Node3D

signal start_game
signal game_over

func on_died() -> void:
	pass # Replace with function body.

func _ready() -> void:
	start()

func start() -> void:
	emit_signal("start_game")
