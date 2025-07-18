extends Node

@export var music_volume: int = 20
@export var ambient_volume: int = 50
@export var sound_effects_volume: int = 100

signal music_volume_changed(value: int)
signal ambient_volume_changed(value: int)
signal sound_effects_volume_changed(value: int)

func _ready() -> void:
	# Load saved options if available
	load_options()

func set_music_volume(value: int) -> void:
	music_volume = value
	emit_signal("music_volume_changed", value)

func set_ambient_volume(value: int) -> void:
	ambient_volume = value
	emit_signal("ambient_volume_changed", value)

func set_sound_effects_volume(value: int) -> void:
	sound_effects_volume = value
	emit_signal("sound_effects_volume_changed", value)

func set_resolution(resolution : Vector2i) -> void:
	DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


var config_file := ConfigFile.new()
const SAVE_PATH = "user://options.cfg"

func save_options():
	config_file.set_value("music", "volume", music_volume)
	config_file.set_value("ambient", "volume", ambient_volume)
	config_file.set_value("sound_effect", "volume", sound_effects_volume)
	config_file.save(SAVE_PATH)

func load_options():
	if config_file.load(SAVE_PATH) == OK:
		set_music_volume(config_file.get_value("music", "volume", music_volume))
		set_ambient_volume(config_file.get_value("ambient", "volume", ambient_volume))
		set_sound_effects_volume(config_file.get_value("sound_effect", "volume", sound_effects_volume))

