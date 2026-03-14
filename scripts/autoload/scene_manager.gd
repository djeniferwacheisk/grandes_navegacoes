extends CanvasLayer

signal transition_started
signal transition_midpoint
signal transition_finished

var _color_rect: ColorRect
var _is_transitioning := false


func _ready() -> void:
	layer = 100
	_color_rect = ColorRect.new()
	_color_rect.color = Color.BLACK
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_color_rect.modulate.a = 0.0
	add_child(_color_rect)


func change_scene(scene_path: String, fade_duration: float = 0.5) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	transition_started.emit()

	_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween()
	tween.tween_property(_color_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished

	transition_midpoint.emit()
	get_tree().change_scene_to_file(scene_path)

	await get_tree().process_frame

	var tween2 := create_tween()
	tween2.tween_property(_color_rect, "modulate:a", 0.0, fade_duration)
	await tween2.finished

	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false
	transition_finished.emit()


func change_scene_packed(scene: PackedScene, fade_duration: float = 0.5) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	transition_started.emit()

	_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween()
	tween.tween_property(_color_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished

	transition_midpoint.emit()
	get_tree().change_scene_to_packed(scene)

	await get_tree().process_frame

	var tween2 := create_tween()
	tween2.tween_property(_color_rect, "modulate:a", 0.0, fade_duration)
	await tween2.finished

	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false
	transition_finished.emit()
