extends Node2D

# ── Faixas de movimento ───────────────────────────────────────────────────────
@export var lane_y_positions: Array[float] = [180.0, 320.0, 460.0]
@export var lane_snap_speed: float = 8.0

# ── Vida ──────────────────────────────────────────────────────────────────────
@export var max_health: float = 100.0
var health: float = 100.0

# ── Sprites de dano ───────────────────────────────────────────────────────────
@export var sprite_intact:   Texture2D
@export var sprite_light:    Texture2D
@export var sprite_medium:   Texture2D
@export var sprite_critical: Texture2D
@export var sprite_sinking:  Texture2D

# ── Invencibilidade após dano ─────────────────────────────────────────────────
@export var invincibility_duration: float = 1.5

# ── Sinais ────────────────────────────────────────────────────────────────────
signal health_changed(current: float, maximum: float)
signal ship_destroyed()

# ── Internos ──────────────────────────────────────────────────────────────────
var current_lane: int = 1
var is_invincible: bool = false
var _inv_timer: float = 0.0
var _flash_timer: float = 0.0
var _flash_visible: bool = true

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	position.y = lane_y_positions[current_lane]
	_update_sprite()


func _process(delta: float) -> void:
	# Movimento entre faixas
	if Input.is_action_just_pressed("move_up"):
		current_lane = max(0, current_lane - 1)
	if Input.is_action_just_pressed("move_down"):
		current_lane = min(lane_y_positions.size() - 1, current_lane + 1)

	# Suaviza o movimento até a faixa
	position.y = lerp(position.y, lane_y_positions[current_lane], lane_snap_speed * delta)

	# Flash de invencibilidade
	if is_invincible:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			_flash_visible = !_flash_visible
			sprite.visible = _flash_visible
			_flash_timer = 0.1
		_inv_timer -= delta
		if _inv_timer <= 0.0:
			is_invincible = false
			sprite.visible = true


func take_damage(amount: float) -> void:
	if is_invincible:
		return
	health = max(0.0, health - amount)
	emit_signal("health_changed", health, max_health)
	_update_sprite()
	if health <= 0.0:
		emit_signal("ship_destroyed")
	else:
		is_invincible = true
		_inv_timer = invincibility_duration
		_flash_timer = 0.1


func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	emit_signal("health_changed", health, max_health)
	_update_sprite()


func _update_sprite() -> void:
	var ratio := health / max_health
	if ratio <= 0.0 and sprite_sinking:
		sprite.texture = sprite_sinking
	elif ratio <= 0.25 and sprite_critical:
		sprite.texture = sprite_critical
	elif ratio <= 0.5 and sprite_medium:
		sprite.texture = sprite_medium
	elif ratio <= 0.8 and sprite_light:
		sprite.texture = sprite_light
	elif sprite_intact:
		sprite.texture = sprite_intact
