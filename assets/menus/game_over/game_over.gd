extends Control

@export var score_label: Label
@export var highscore_label: Label

signal start_game
signal main_menu

func _ready() -> void:
	visible = false
	set_process(false)

func _on_start_button_pressed() -> void:
	visible = false
	emit_signal("start_game")

func _on_menu_button_pressed() -> void:
	visible = false
	emit_signal("main_menu")

func Show() -> void:
	visible = true
	set_process(true)

func set_score(value: int, highscore: int) -> void:
	if value > highscore:
		score_label.text = "New Highscore: " + str(value).pad_zeros(5)
		highscore_label.text = "Highscore: " + str(value).pad_zeros(5)
	else:
		score_label.text = "Score: " + str(value).pad_zeros(5)
		highscore_label.text = "Highscore: " + str(highscore).pad_zeros(5)
