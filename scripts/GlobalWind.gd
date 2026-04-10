extends Node

var wind_direction: float = 0.0
var wind_strength: float = 20.0

var change_timer: float = 0.0
var change_interval: float = 100.0


func _process(delta):

	change_timer += delta
	
	if change_timer >= change_interval:
		randomize_wind()
		change_timer = 0.0


func get_wind_vector() -> Vector2:
	return Vector2.DOWN.rotated(deg_to_rad(wind_direction)) * wind_strength


func randomize_wind():
	wind_direction = randf_range(0,360)
