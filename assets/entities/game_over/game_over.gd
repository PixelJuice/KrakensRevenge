extends Control

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