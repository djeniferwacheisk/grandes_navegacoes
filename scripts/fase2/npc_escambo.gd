extends Area2D

var jogador_por_perto := false

@onready var label_interagir: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	label_interagir.visible = false

func _process(_delta: float) -> void:
	if not jogador_por_perto:
		return
	if Input.is_action_just_pressed("interact"):
		_abrir_escambo()

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	jogador_por_perto = true
	label_interagir.visible = true

func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	jogador_por_perto = false
	label_interagir.visible = false

func _abrir_escambo() -> void:
	print("abrindo escambo")
	var escambo_scene = preload("res://scenes/levels/Fase 2/escambo.tscn")
	var escambo = escambo_scene.instantiate()
	get_tree().root.add_child(escambo)
	print("escambo adicionado: ", escambo)
	print("visivel: ", escambo.visible)
