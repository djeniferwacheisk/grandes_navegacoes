## ShipResourceManager.gd
## Gerencia os recursos da tripulação na Fase 4 — Objetivo 1
## Água, Comida e Moral decaem com o tempo e afetam o navio

extends Node

signal resource_changed(resource: String, value: float)
signal resource_critical(resource: String)
signal resource_depleted(resource: String)
signal all_resources_ok()

# Recursos principais
var water: float = 100.0
var food: float = 100.0
var morale: float = 100.0

const MAX_VALUE := 100.0
const MIN_OK := 20.0  # Abaixo disso é crítico

# Taxas de decaimento por segundo
var decay_rate_water: float = 1.2
var decay_rate_food: float = 0.8
var decay_rate_morale: float = 0.5

# Referência ao navio para aplicar efeitos
var ship_ref: Node = null

# Controla se o sistema está ativo
var active: bool = false


func start(ship: Node) -> void:
	ship_ref = ship
	active = true


func stop() -> void:
	active = false


func _process(delta: float) -> void:
	if not active:
		return

	_decay_resources(delta)
	apply_low_resource_effects()
	check_failure()


func _decay_resources(delta: float) -> void:
	water = clamp(water - decay_rate_water * delta, 0.0, MAX_VALUE)
	food  = clamp(food  - decay_rate_food  * delta, 0.0, MAX_VALUE)
	morale = clamp(morale - decay_rate_morale * delta, 0.0, MAX_VALUE)

	resource_changed.emit("water",  water)
	resource_changed.emit("food",   food)
	resource_changed.emit("morale", morale)

	# Sinais de crítico
	if water  < MIN_OK: resource_critical.emit("water")
	if food   < MIN_OK: resource_critical.emit("food")
	if morale < MIN_OK: resource_critical.emit("morale")


func add_water(amount: float) -> void:
	water = clamp(water + amount, 0.0, MAX_VALUE)
	resource_changed.emit("water", water)


func add_food(amount: float) -> void:
	food = clamp(food + amount, 0.0, MAX_VALUE)
	resource_changed.emit("food", food)


func add_morale(amount: float) -> void:
	morale = clamp(morale + amount, 0.0, MAX_VALUE)
	resource_changed.emit("morale", morale)


func apply_low_resource_effects() -> void:
	if not ship_ref:
		return
	# Água baixa → navio mais lento
	if water < MIN_OK and ship_ref.has_method("set_speed_multiplier"):
		ship_ref.set_speed_multiplier(0.5)
	# Comida baixa → aceleração reduzida
	elif food < MIN_OK and ship_ref.has_method("set_speed_multiplier"):
		ship_ref.set_speed_multiplier(0.7)
	else:
		if ship_ref.has_method("set_speed_multiplier"):
			ship_ref.set_speed_multiplier(1.0)


func check_failure() -> bool:
	if water <= 0.0:
		resource_depleted.emit("water")
		return true
	if food <= 0.0:
		resource_depleted.emit("food")
		return true
	if morale <= 0.0:
		resource_depleted.emit("morale")
		return true
	return false


func all_above_minimum() -> bool:
	return water > MIN_OK and food > MIN_OK and morale > MIN_OK
