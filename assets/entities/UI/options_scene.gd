extends Control

signal back_button

func _ready() -> void:
	visible = false

func _on_back_button_pressed() -> void:
	visible = false
	Options.save_options()
	emit_signal("back_button")

func Show() -> void:
	visible = true
	$%back_button.grab_focus()