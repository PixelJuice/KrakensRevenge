extends MarginContainer

@export var boost : Boost
@export var health : Health

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
	health.value = health.max_value
	boost.value = boost.max_value

func hide_hud() -> void:
	visible = false



