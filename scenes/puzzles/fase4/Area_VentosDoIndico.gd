## Area_VentosDoIndico.gd
## Fase 4 — Objetivo 2: "Os Ventos do Índico"
## O jogador navega por uma área de monções, desviando de recifes e
## aproveitando rajadas de vento favoráveis para alcançar Calecute.

extends Node2D

var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

signal objetivo_concluido()
signal carta_coletada()
signal aviso(texto: String)

var _concluido      := false
var _carta_coletada := false
var _ventos_favoraveis_ativos := 0

@onready var barco:        CharacterBody2D = $Barco
@onready var zona_chegada: Area2D          = $ZonaChegada
@onready var carta_area:   Area2D          = $CartaNavegacao
@onready var zonas_vento:  Node2D          = $ZonasVento
@onready var label_aviso:  Label           = $CanvasLayer/LabelAviso
@onready var label_vento:  Label           = $CanvasLayer/LabelVento


func _ready() -> void:
	add_to_group("area_fase4")

	await get_tree().process_frame
	var cam := get_node_or_null("Barco/Camera2D")
	if cam:
		cam.zoom = Vector2(2, 2)
	if barco:
		barco.motor_max_speed = 60.0
		if barco.has_signal("health_changed"):
			barco.health_changed.connect(_on_barco_dano)
	_setup_camera()

	zona_chegada.body_entered.connect(_on_chegada)
	carta_area.body_entered.connect(_on_carta)

	for zona in zonas_vento.get_children():
		if zona is WindArea:
			zona.ship_entered_wind.connect(_on_ship_entered_wind)
			zona.ship_exited_wind.connect(_on_ship_exited_wind)

	_mostrar_aviso("Siga as setas verdes: elas indicam ventos favoráveis até Calecute!", 4.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)
		get_viewport().set_input_as_handled()


func _on_ship_entered_wind(is_favorable: bool) -> void:
	if is_favorable:
		_ventos_favoraveis_ativos += 1
		label_vento.text = "💨 Vento a favor — ganhando velocidade!"
		label_vento.modulate = Color(0.4, 1.0, 0.4, 1.0)
		label_vento.visible = true
		if barco:
			barco.set_speed_multiplier(1.0)
			_pulso_velocidade()
	else:
		label_vento.text = "⚠ Vento contrário — cuidado com os recifes!"
		label_vento.modulate = Color(1.0, 0.5, 0.2, 1.0)
		label_vento.visible = true
		if barco:
			barco.set_speed_multiplier(0.7)


func _on_ship_exited_wind() -> void:
	if _ventos_favoraveis_ativos > 0:
		_ventos_favoraveis_ativos -= 1
	label_vento.visible = false
	if barco:
		barco.set_speed_multiplier(1.0)


func _pulso_velocidade() -> void:
	if not barco:
		return
	var sprite := barco.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		return
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(0.7, 1.0, 0.7, 1.0), 0.15)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.35)


func _on_barco_dano(current: float, max_health: float) -> void:
	if current <= 0:
		return
	_mostrar_aviso("O casco bateu num recife e sofreu avarias!", 2.5)


func _on_carta(body: Node) -> void:
	if _carta_coletada or not body.is_in_group("barco"):
		return
	_carta_coletada = true
	carta_area.queue_free()
	GameManager.add_item("Carta de Navegação Árabe", "Revela detalhes dos ventos e rotas do Índico.")
	GameManager.set_phase_flag(4, "carta_navegacao_arabe", true)
	GameManager.reveal_minimap_area("indico")
	_mostrar_aviso("Carta de Navegação Árabe adquirida! O minimapa agora mostra mais detalhes.", 3.0)
	carta_coletada.emit()


func _on_chegada(body: Node) -> void:
	if _concluido or not body.is_in_group("barco"):
		return
	var navio_ok: bool = not is_instance_valid(barco) or barco.health > 0
	if navio_ok:
		_concluir()
	else:
		_mostrar_aviso("O navio precisa estar funcional para continuar.")
		aviso.emit("O navio precisa estar funcional para continuar.")


func _concluir() -> void:
	_concluido = true
	_mostrar_aviso("Dominando os ventos do Índico, a expedição avança!", 2.0)
	aviso.emit("Dominando os ventos do Índico, a expedição avança!")
	objetivo_concluido.emit()
	await get_tree().create_timer(2.0).timeout
	GameManager.complete_objective(4, "ventos_indico")
	GameManager.save_game()
	SceneManager.change_scene("res://scenes/levels/fase4/Level4_RumoAsIndias.tscn")


func _mostrar_aviso(texto: String, duracao: float = 3.5) -> void:
	if not label_aviso:
		return
	label_aviso.text    = texto
	label_aviso.visible = true
	await get_tree().create_timer(duracao).timeout
	if is_instance_valid(label_aviso):
		label_aviso.visible = false


func _setup_camera() -> void:
	await get_tree().process_frame
	var cam := get_node_or_null("Barco/Camera2D")
	if cam:
		cam.limit_left   = -600
		cam.limit_top    = -600
		cam.limit_right  = 2000
		cam.limit_bottom = 600
