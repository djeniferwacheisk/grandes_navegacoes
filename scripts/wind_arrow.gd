extends TextureRect

func _process(delta):
	rotation = deg_to_rad(GlobalWind.wind_direction)
