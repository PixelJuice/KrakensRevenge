extends Control

signal start_button
signal quit_button

func _on_start_button_pressed() -> void:
	visible = false
	emit_signal("start_button")

func _on_quit_button_pressed() -> void:
	emit_signal("quit_button")

func Show() -> void:
	visible = true
