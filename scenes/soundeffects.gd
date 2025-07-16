extends AudioStreamPlayer

var polyphonic_player

#@onready var polyphonic_player = $AudioStreamPlayerPolyphonic
@onready var eat_1 = preload("res://assets/Sound/troll_monster_battle_groan_01.wav")
@onready var eat_2 = preload("res://assets/Sound/zombie_voice_eating_chewing_01.wav")

func _ready() -> void:
	play()
	polyphonic_player = get_stream_playback()

func on_eating():
	# Play eating sound effect
	volume_linear = .75
	var stream_1 = polyphonic_player.play_stream(eat_1)
	polyphonic_player.set_stream_pitch_scale(stream_1, randf_range(0.7, 1.2))
	var stream_2 = polyphonic_player.play_stream(eat_2)
	polyphonic_player.set_stream_pitch_scale(stream_2, randf_range(0.7, 1.2))

	#set_playing(true)
