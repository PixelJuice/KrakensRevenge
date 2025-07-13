extends Control

@export var game_start_label: RichTextLabel
@export var countdownLabel: RichTextLabel
@export var countdownTime: float = 5.0

func start() -> void:
	visible = true
	countdownTime = 5.0
	countdownLabel.text = str(ceil(countdownTime)) + "..."
	get_tree().paused = true # Pause the game until countdown is over
	_start_countdown()

func _process(delta: float) -> void:
	if countdownTime > 0:
		countdownTime -= delta
		countdownLabel.text = str(int(ceil(countdownTime))) + "..."
	else:
		visible = false
		get_tree().paused = false # Unpause the game when countdown is over

func _start_countdown() -> void:
	countdownLabel.visible = true
	countdownLabel.text = str(ceil(countdownTime))
