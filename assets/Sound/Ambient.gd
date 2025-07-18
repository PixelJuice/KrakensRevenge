extends AudioStreamPlayer

func _ready() -> void:
	Options.ambient_volume_changed.connect(_on_ambient_volume_changed)
	volume_linear = Options.ambient_volume / 100.0

func _on_ambient_volume_changed(value: int) -> void:
	volume_linear = value / 100.0

func _process(_delta):
	if not is_playing():
		play()