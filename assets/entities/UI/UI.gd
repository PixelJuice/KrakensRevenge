extends MarginContainer

@export var boost : Boost
@export var health : Health
@export var score : Label

func _ready() -> void:
	hide_hud()

func _set_boost_value(value) :
	boost.value = value

func _set_health_value(value) :
	health.value = value

func _set_max_boost_value(value) :
	boost.max_value = value

func _set_max_health_value(value) :
	health.max_value = value

func show_hud() -> void:
	visible = true

func hide_hud() -> void:
	visible = false
	reset()

func set_score(value: int) -> void:
	score.text = "Score: " + str(value).pad_zeros(5)

func reset() -> void:
	_set_health_value(health.max_value)
	_set_boost_value(boost.max_value)
	set_score(0)



