extends Control

class_name SoundOptions

@export var music_volume: HSlider
@export var effects_volume: HSlider
@export var ambient_volume: HSlider

func _ready() -> void:
	music_volume.value = Options.music_volume
	effects_volume.value = Options.sound_effects_volume
	ambient_volume.value = Options.ambient_volume

func _on_Music_value_changed(value : float) -> void:
	Options.set_music_volume(int(value))

func _on_Effects_value_changed(value : float) -> void:
	Options.set_sound_effects_volume(int(value))

func _on_Ambient_value_changed(value : float) -> void:
	Options.set_ambient_volume(int(value))