extends MarginContainer

@export var boost : Boost
@export var health : Health

signal Died

func _set_boost_value(value) :
	boost.value = value

func _set_health_value(value) :
	health.value = value

func _process(delta: float) -> void:
	health.value -= 500 * delta
	if health.value == 0:
		Died.emit()
