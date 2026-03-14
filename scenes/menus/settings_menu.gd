extends CanvasLayer

@onready var music_slider: HSlider = $Panel/MusicSlider
@onready var sfx_slider: HSlider = $Panel/SFXSlider
@onready var back_button: Button = $Panel/BackButton


func _ready() -> void:
	music_slider.value = AudioManager.music_volume
	sfx_slider.value = AudioManager.sfx_volume
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back)
	back_button.grab_focus()


func _on_music_changed(value: float) -> void:
	AudioManager.music_volume = value


func _on_sfx_changed(value: float) -> void:
	AudioManager.sfx_volume = value


func _on_back() -> void:
	queue_free()
