extends Control

@export var score_label: Label
@export var highscore_label: Label
@onready var animationPlayer = $AnimationPlayer

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
	modulate = Color(1, 1, 1, 0)
	animationPlayer.play("show")
	get_tree().get_root().set_process_input(false)
	$%restart.grab_focus()
	set_process(true)
	visible = true


func set_score(value: int, highscore: int) -> void:
	if value > highscore:
		score_label.text = "NEW HIGHSCORE: " + str(value).pad_zeros(5)
		highscore_label.text = "HIGHSCORE: " + str(value).pad_zeros(5)
	else:
		score_label.text = "SCORE: " + str(value).pad_zeros(5)
		highscore_label.text = "HIGHSCORE: " + str(highscore).pad_zeros(5)


func _on_animationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "show":
		get_tree().get_root().set_process_input(true)
