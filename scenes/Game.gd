class_name Game
extends Node3D

@export var score_multiplier: int = 100

var highscore: int = 0
var score: int = 0
const SAVE_PATH = "user://highscore.save"

signal start_game
signal score_changed(score: int)
signal final_score(score: int, highscore: int)

func on_died() -> void:
	emit_signal("final_score", score, highscore)
	try_set_new_highscore(score)

func start() -> void:
	emit_signal("start_game")

func quit() -> void:
	print("Quitting game...")
	get_tree().quit()

func change_score(value: int) -> void:
	score = value * score_multiplier
	emit_signal("score_changed", score)

func _ready():
	load_highscore()

func load_highscore():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		highscore = file.get_32()
		file.close()
	else:
		highscore = 0

func save_highscore():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(highscore)
	file.close()

func try_set_new_highscore(value: int):
	if value > highscore:
		highscore = value
		save_highscore()
		return true
	return false