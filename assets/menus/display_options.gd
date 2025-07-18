extends Control


func set_resolution(resolution: int) -> void:
	if resolution == 0:
		Options.set_resolution(Vector2i(1280, 720))
	elif resolution == 1:
		Options.set_resolution(Vector2i(1920, 1080))
	elif resolution == 2:
		Options.set_resolution(Vector2i(2560, 1440))
	elif resolution == 3:
		Options.set_resolution(Vector2i(3840, 2160))
	else:
		print("Invalid resolution option selected.")