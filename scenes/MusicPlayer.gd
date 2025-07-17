extends AudioStreamPlayer


func _process(_delta):
	if not is_playing():
		pass
		play_music()

func play_music() -> void:
	volume_linear = 0.2
	stream = load("res://assets/Sound/music_epic_orchestral_bg_underscore.wav")
	set_playing(true)

func play_died() -> void:
	volume_linear = 0.2
	stream = load("res://assets/Sound/Casual Lose 2.wav")
	set_playing(true)
