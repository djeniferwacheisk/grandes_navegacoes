extends Node2D

# ─── Configurações de faixas ─────────────────────────────────────────────────
@export var lane_y_positions: Array[float] = [180.0, 320.0, 460.0]  # Y de cada faixa (cima/meio/baixo)
@export var lane_snap_speed: float = 8.0       # Velocidade de interpolação entre faixas

# ─── Configurações de dano ───────────────────────────────────────────────────
@export var max_integrity: int = 5
@export var invincibility_duration: float = 1.5  # Segundos de invencibilidade após dano
@export var flash_interval: float = 0.1          # Intervalo do flash ao tomar dano

# ─── Sprites de dano (arraste do FileSystem para o Inspetor) ─────────────────
@export var sprite_intact:   Texture2D   # ship_intact.png
@export var sprite_light:    Texture2D   # ship_damage_light.png
@export var sprite_medium:   Texture2D   # ship_damage_medium.png
@export var sprite_critical: Texture2D   # ship_damage_critical.png
@export var sprite_sinking:  Texture2D   # ship_sinking.png

# ─── Sinais ──────────────────────────────────────────────────────────────────
signal integrity_changed(current: int, maximum: int)
signal ship_destroyed()
signal lane_changed(new_lane: int)

# ─── Estado interno ──────────────────────────────────────────────────────────
var current_lane: int = 1          # 0 = cima, 1 = meio, 2 = baixo
var current_integrity: int
var is_invincible: bool = false
var is_destroyed: bool = false
var _flash_timer: float = 0.0
var _invincible_timer: float = 0.0
var _flash_visible: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: Area2D = $HurtBox


func _ready() -> void:
	current_integrity = max_integrity
	position.y = lane_y_positions[current_lane]
	_update_sprite()


func _process(delta: float) -> void:
	if is_destroyed:
		return

	_handle_lane_input()
	_smooth_lane_movement(delta)
	_tick_invincibility(delta)


# ─── Movimento entre faixas ──────────────────────────────────────────────────

func _handle_lane_input() -> void:
	if Input.is_action_just_pressed("ui_up"):
		_change_lane(-1)
	elif Input.is_action_just_pressed("ui_down"):
		_change_lane(1)


func _change_lane(direction: int) -> void:
	var new_lane := clamp(current_lane + direction, 0, lane_y_positions.size() - 1)
	if new_lane == current_lane:
		return
	current_lane = new_lane
	emit_signal("lane_changed", current_lane)


func _smooth_lane_movement(delta: float) -> void:
	var target_y := lane_y_positions[current_lane]
	position.y = lerp(position.y, target_y, lane_snap_speed * delta)


# ─── Sistema de dano ─────────────────────────────────────────────────────────

func take_damage(amount: int = 1) -> void:
	if is_invincible or is_destroyed:
		return

	current_integrity = max(0, current_integrity - amount)
	emit_signal("integrity_changed", current_integrity, max_integrity)
	_update_sprite()

	if current_integrity <= 0:
		_trigger_destruction()
	else:
		_start_invincibility()


func heal(amount: int = 1) -> void:
	if is_destroyed:
		return
	current_integrity = min(max_integrity, current_integrity + amount)
	emit_signal("integrity_changed", current_integrity, max_integrity)
	_update_sprite()


func _start_invincibility() -> void:
	is_invincible = true
	_invincible_timer = invincibility_duration
	_flash_timer = flash_interval


func _tick_invincibility(delta: float) -> void:
	if not is_invincible:
		return

	# Pisca o sprite durante invencibilidade
	_flash_timer -= delta
	if _flash_timer <= 0.0:
		_flash_visible = not _flash_visible
		sprite.visible = _flash_visible
		_flash_timer = flash_interval

	_invincible_timer -= delta
	if _invincible_timer <= 0.0:
		is_invincible = false
		sprite.visible = true


func _trigger_destruction() -> void:
	is_destroyed = true
	is_invincible = false
	sprite.visible = true
	_update_sprite()  # mostra sprite afundando
	collision.monitoring = false
	collision.monitorable = false
	emit_signal("ship_destroyed")

	# Aguarda animação de afundamento antes de sinalizar game over
	await get_tree().create_timer(2.0).timeout
	# O GameManager ou a cena pai escuta "ship_destroyed" para exibir a tela de falha


# ─── Troca de sprite conforme integridade ────────────────────────────────────

func _update_sprite() -> void:
	if is_destroyed:
		sprite.texture = sprite_sinking
		return

	var ratio := float(current_integrity) / float(max_integrity)
	if ratio > 0.8:
		sprite.texture = sprite_intact
	elif ratio > 0.5:
		sprite.texture = sprite_light
	elif ratio > 0.25:
		sprite.texture = sprite_medium
	else:
		sprite.texture = sprite_critical


# ─── Utilitário público ──────────────────────────────────────────────────────

func get_integrity_ratio() -> float:
	return float(current_integrity) / float(max_integrity)
