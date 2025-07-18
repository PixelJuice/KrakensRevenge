extends AudioStreamPlayer

func _ready():
	Options.music_volume_changed.connect(_on_music_volume_changed)
	volume_linear = Options.music_volume / 100.0



func _on_music_volume_changed(value: int) -> void:
	volume_linear = value / 100.0
	print("Music volume changed to: ", value)

func _process(_delta):
	if not is_playing():
		play_music()

func play_music() -> void:
	stream = load("res://assets/Sound/music_epic_orchestral_bg_underscore.wav")
	set_playing(true)

func play_died() -> void:
	stream = load("res://assets/Sound/Casual Lose 2.wav")
	set_playing(true)
