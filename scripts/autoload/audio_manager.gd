extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var music_volume: float = 0.8:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		if music_player:
			music_player.volume_db = linear_to_db(music_volume)

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)

var _fade_tween: Tween


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = linear_to_db(music_volume)
	add_child(music_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)


func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if music_player.stream == stream and music_player.playing:
		return

	if _fade_tween:
		_fade_tween.kill()

	if music_player.playing:
		_fade_tween = create_tween()
		_fade_tween.tween_property(music_player, "volume_db", -40.0, fade_duration)
		await _fade_tween.finished

	music_player.stream = stream
	music_player.volume_db = linear_to_db(music_volume)
	music_player.play()


func stop_music(fade_duration: float = 1.0) -> void:
	if not music_player.playing:
		return

	if _fade_tween:
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(music_player, "volume_db", -40.0, fade_duration)
	await _fade_tween.finished
	music_player.stop()


func play_sfx(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.bus = "Master"
	player.volume_db = linear_to_db(sfx_volume)
	player.stream = stream
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
