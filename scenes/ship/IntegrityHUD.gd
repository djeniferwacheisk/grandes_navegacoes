extends CanvasLayer

# ─── Referências ─────────────────────────────────────────────────────────────
@onready var bar: TextureProgressBar = $IntegrityBar
@onready var crack_overlay: TextureRect  = $CrackOverlay   # overlay de rachaduras
@onready var danger_vignette: ColorRect  = $DangerVignette # vermelho pulsante em perigo

# ─── Configurações ───────────────────────────────────────────────────────────
@export var danger_threshold: float = 0.40   # abaixo disso ativa vinheta vermelha
@export var pulse_speed: float = 2.5
@export var shake_magnitude: float = 6.0
@export var shake_duration: float = 0.3

# ─── Texturas para estados de dano (opcional — aparece sobre o sprite) ───────
@export var crack_textures: Array[Texture2D]  # 0 = leve, 1 = médio, 2 = crítico

var _pulse_time: float = 0.0
var _shake_timer: float = 0.0
var _original_position: Vector2


func _ready() -> void:
	_original_position = position
	danger_vignette.modulate.a = 0.0
	if crack_overlay:
		crack_overlay.visible = false


func _process(delta: float) -> void:
	_tick_danger_pulse(delta)
	_tick_screen_shake(delta)


# ─── Conectar ao sinal do navio ───────────────────────────────────────────────
# No _ready() da cena principal:
#   ship.integrity_changed.connect(hud.on_integrity_changed)

func on_integrity_changed(current: int, maximum: int) -> void:
	var ratio := float(current) / float(maximum)

	# Atualiza a barra (TextureProgressBar usa value de 0 a max)
	bar.max_value = maximum
	bar.value    = current

	# Troca overlay de rachaduras
	_update_crack_overlay(ratio)

	# Aciona tela vermelha se crítico
	if ratio <= danger_threshold:
		_enable_danger_pulse(true)
	else:
		_enable_danger_pulse(false)
		danger_vignette.modulate.a = 0.0

	# Treme a câmera ao tomar dano
	_start_screen_shake()


# ─── Overlay de rachaduras ───────────────────────────────────────────────────

func _update_crack_overlay(ratio: float) -> void:
	if crack_overlay == null or crack_textures.is_empty():
		return
	crack_overlay.visible = ratio < 0.8
	if ratio > 0.5:
		crack_overlay.texture = crack_textures[0] if crack_textures.size() > 0 else null
	elif ratio > 0.25:
		crack_overlay.texture = crack_textures[1] if crack_textures.size() > 1 else null
	else:
		crack_overlay.texture = crack_textures[2] if crack_textures.size() > 2 else null


# ─── Pulsação vermelha ───────────────────────────────────────────────────────

var _danger_active: bool = false

func _enable_danger_pulse(active: bool) -> void:
	_danger_active = active
	if not active:
		_pulse_time = 0.0


func _tick_danger_pulse(delta: float) -> void:
	if not _danger_active:
		return
	_pulse_time += delta * pulse_speed
	danger_vignette.modulate.a = (sin(_pulse_time) * 0.5 + 0.5) * 0.4  # 0 a 0.4


# ─── Screen shake ────────────────────────────────────────────────────────────

func _start_screen_shake() -> void:
	_shake_timer = shake_duration


func _tick_screen_shake(delta: float) -> void:
	if _shake_timer <= 0.0:
		position = _original_position
		return
	_shake_timer -= delta
	var strength := (_shake_timer / shake_duration) * shake_magnitude
	position = _original_position + Vector2(
		randf_range(-strength, strength),
		randf_range(-strength, strength)
	)
