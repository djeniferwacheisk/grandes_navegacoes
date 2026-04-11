extends CanvasLayer

@onready var music_slider: HSlider = $Root/Caixa/Conteudo/PergaminhoSom/SliderMusica
@onready var sfx_slider: HSlider = $Root/Caixa/Conteudo/PergaminhoSom/SliderEfeitos
@onready var brightness_slider: HSlider = $Root/Caixa/Conteudo/PergaminhoVisao/SliderBrilho
@onready var back_button: Button = $Root/Caixa/BotaoFechar
@onready var overlay: ColorRect = $Root/Overlay


func _ready() -> void:
	brightness_slider.value = _get_brightness()

	if "music_volume" in AudioManager:
		music_slider.value = AudioManager.music_volume
		sfx_slider.value = AudioManager.sfx_volume
	else:
		music_slider.value = 0.8
		sfx_slider.value = 0.8

	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	brightness_slider.value_changed.connect(_on_brightness_changed)
	back_button.pressed.connect(_on_back)

	# Animação de abertura
	$Root/Caixa.scale = Vector2(0.85, 0.85)
	$Root/Caixa.modulate.a = 0.0
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property($Root/Caixa, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_property($Root/Caixa, "modulate:a", 1.0, 0.2)


func _get_brightness() -> float:
	return 1.0 - overlay.color.a


func _on_music_changed(value: float) -> void:
	AudioManager.music_volume = value
	var bus_idx := AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
		AudioServer.set_bus_mute(bus_idx, value < 0.01)


func _on_sfx_changed(value: float) -> void:
	AudioManager.sfx_volume = value
	var bus_idx := AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
		AudioServer.set_bus_mute(bus_idx, value < 0.01)


func _on_brightness_changed(value: float) -> void:
	overlay.color.a = 1.0 - value


func _on_back() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN)
	tween.set_parallel(true)
	tween.tween_property($Root/Caixa, "scale", Vector2(0.85, 0.85), 0.2)
	tween.tween_property($Root/Caixa, "modulate:a", 0.0, 0.18)
	await tween.finished
	queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_back()
