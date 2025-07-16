extends AudioStreamPlayer


func _ready() -> void:
	play_music()

func _process(_delta):
	if not is_playing():
		play_music()

func play_music() -> void:
	volume_linear = 0.75
	stream = load("res://assets/Sound/music_epic_orchestral_bg_underscore.wav")
	set_playing(true)

func play_died() -> void:
	volume_linear = 0.75
	stream = load("res://assets/Sound/Casual Lose 2.wav")
	set_playing(true)
