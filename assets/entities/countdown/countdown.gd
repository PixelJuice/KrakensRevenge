extends Control

@export var game_start_label: RichTextLabel
@export var countdownLabel: RichTextLabel
@export var COUNTDOWN_TIME: float = 5.0
var currentCountdownTime: float = 5.0

func start() -> void:
	visible = true
	currentCountdownTime = COUNTDOWN_TIME
	countdownLabel.text = str(ceil(currentCountdownTime)) + "..."
	get_tree().paused = true # Pause the game until countdown is over

func _process(delta: float) -> void:
	if currentCountdownTime > 0:
		currentCountdownTime -= delta
		countdownLabel.text = str(int(ceil(currentCountdownTime))) + "..."
	else:
		visible = false
		get_tree().paused = false # Unpause the game when countdown is over
