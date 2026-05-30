extends Node

signal phase_changed(phase: int)
signal objective_completed(phase: int, objective: String)
signal item_collected(item_name: String)
signal minimap_area_revealed(area_id: String)

var current_phase: int = 1
var inventory: Array[Dictionary] = []
var objectives_completed: Dictionary = {}
var minimap_revealed: Array[String] = []
var phase_data: Dictionary = {}

const SAVE_PATH := "user://save_data.json"


static func _default_objectives() -> Dictionary:
	return {
		1: {"bussola_ventos": false, "caravela": false, "astrolabio": false},
		4: {"tripulacao_viva": false, "ventos_indico": false, "carta_navegacao": false, "mercado_calecute": false},
	}


func _ready() -> void:
	objectives_completed = _default_objectives()
	load_game()


func add_item(item_name: String, description: String = "", icon_path: String = "") -> void:
	for item in inventory:
		if item["name"] == item_name:
			item["quantity"] = item.get("quantity", 1) + 1
			item_collected.emit(item_name)
			return
	inventory.append({
		"name": item_name,
		"description": description,
		"icon": icon_path,
		"quantity": 1,
	})
	item_collected.emit(item_name)


func has_item(item_name: String) -> bool:
	for item in inventory:
		if item["name"] == item_name:
			return true
	return false


func get_item_count(item_name: String) -> int:
	for item in inventory:
		if item["name"] == item_name:
			return item.get("quantity", 1)
	return 0


func complete_objective(phase: int, objective: String) -> void:
	if not objectives_completed.has(phase):
		objectives_completed[phase] = {}
	objectives_completed[phase][objective] = true
	objective_completed.emit(phase, objective)
	if is_phase_complete(phase):
		phase_changed.emit(phase + 1)


func is_objective_complete(phase: int, objective: String) -> bool:
	if objectives_completed.has(phase) and objectives_completed[phase].has(objective):
		return objectives_completed[phase][objective]
	return false


func is_phase_complete(phase: int) -> bool:
	if not objectives_completed.has(phase):
		return false
	for obj_key in objectives_completed[phase]:
		if not objectives_completed[phase][obj_key]:
			return false
	return true


func reveal_minimap_area(area_id: String) -> void:
	if area_id not in minimap_revealed:
		minimap_revealed.append(area_id)
		minimap_area_revealed.emit(area_id)


func set_phase_flag(phase: int, key: String, value) -> void:
	if not phase_data.has(phase):
		phase_data[phase] = {}
	phase_data[phase][key] = value


func get_phase_flag(phase: int, key: String, default = null):
	if phase_data.has(phase) and phase_data[phase].has(key):
		return phase_data[phase][key]
	return default


func save_game() -> void:
	var data := {
		"current_phase": current_phase,
		"inventory": inventory,
		"objectives_completed": objectives_completed,
		"minimap_revealed": minimap_revealed,
		"phase_data": phase_data,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return false
	var data: Dictionary = json.data
	current_phase = data.get("current_phase", 1)
	var raw_inventory: Array = data.get("inventory", [])
	inventory.clear()
	for item in raw_inventory:
		inventory.append(item)
	var raw_minimap: Array = data.get("minimap_revealed", [])
	minimap_revealed.clear()
	for area in raw_minimap:
		minimap_revealed.append(area)
	var raw_objectives = data.get("objectives_completed", {})
	objectives_completed = _default_objectives()
	for key in raw_objectives:
		var phase_key := int(key)
		var saved_phase: Dictionary = raw_objectives[key]
		if not objectives_completed.has(phase_key):
			objectives_completed[phase_key] = {}
		for obj_key in saved_phase:
			objectives_completed[phase_key][obj_key] = saved_phase[obj_key]
	var raw_phase_data = data.get("phase_data", {})
	phase_data = {}
	for key in raw_phase_data:
		phase_data[int(key)] = raw_phase_data[key]
	return true


func reset_game() -> void:
	current_phase = 1
	inventory.clear()
	minimap_revealed.clear()
	phase_data.clear()
	objectives_completed = _default_objectives()


# Escambo fase 2

var fragmentos_coletados: int = 0
var fragmentos_ids: Array = []

signal fragmento_coletado(id: String, nome: String)
signal todos_fragmentos_coletados()

func coletar_fragmento(id: String, nome: String) -> void:
	if id in fragmentos_ids:
		return
	fragmentos_ids.append(id)
	fragmentos_coletados += 1
	print("Fragmento coletado: ", nome)
	fragmento_coletado.emit(id, nome)
	if fragmentos_coletados >= 3:
		todos_fragmentos_coletados.emit()

func escambo_completo() -> void:
	print("Escambo realizado com sucesso!")

func puzzle_completo() -> void:
	print("Puzzle do mapa concluído!")
	get_tree().change_scene_to_file("res://scenes/fase3.tscn")