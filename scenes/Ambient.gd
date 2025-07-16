extends AudioStreamPlayer

func _ready() -> void:
	volume_linear = 0.5

func _process(_delta):
	if not is_playing():
		play()