extends Area2D

@export var ponto_id: String = "vegetacao"
@export var ponto_nome: String = "Vegetação Tropical"
@export var abre_escambo: bool = false

var coletado := false
var jogador_por_perto := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if not jogador_por_perto:
		return
	if not abre_escambo:
		return
	print("perto da aldeia, esperando E")
	if Input.is_action_just_pressed("interact"):
		print("E pressionado!")
		_abrir_escambo()

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	jogador_por_perto = true
	if not abre_escambo:
		_coletar()

func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	jogador_por_perto = false

func _coletar() -> void:
	if coletado:
		return
	coletado = true
	GameManager.coletar_fragmento(ponto_id, ponto_nome)
	modulate = Color(0.5, 1.0, 0.5)

func _abrir_escambo() -> void:
	var escambo = get_tree().get_first_node_in_group("escambo")
	if escambo:
		escambo.visible = true
