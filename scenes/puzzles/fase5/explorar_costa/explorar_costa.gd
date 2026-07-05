extends Node2D

var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

var registros_feitos: int = 0
var itens_coletados: Array[String] = []

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox
@onready var polaroid_dim: ColorRect = $PolaroidLayer/Dim
@onready var polaroid_rect: TextureRect = $PolaroidLayer/PolaroidImage
@onready var hud = $HUD

const NOMES_OBJETIVOS := {
	"floresta": "Floresta Tropical",
	"fauna": "Fauna Colorida",
	"morro": "Serra e Morro",
}

const POLAROIDS := {
	"morro": preload("res://assets/fase5/polaroid_morro.png"),
	"floresta": preload("res://assets/fase5/polaroid_floresta.png"),
	"fauna": preload("res://assets/fase5/polaroid_fauna.png"),
}

const ANOTACOES := {
	"morro": [
		{"speaker": "Cartógrafo", "text": "Que serras e morros imponentes! A terra se ergue em direção ao céu, coberta de verde.", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Registro no diário: 'Grandes montes aparecem ao longo da costa. Terra fértil e de beleza singular.'", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ 'Registro da Costa' adicionado ao diário de bordo!", "portrait": ""}
	],
	"floresta": [
		{"speaker": "Cartógrafo", "text": "Jamais vi floresta tão densa! As árvores são enormes, de madeiras nunca vistas na Europa.", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Entre elas avisto o Pau-brasil, madeira de cor vermelha intensa, muito valiosa.", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ 'Madeira de Pau-brasil' adicionada ao diário de bordo!", "portrait": ""}
	],
	"fauna": [
		{"speaker": "Cartógrafo", "text": "Araras vermelhas e tucanos de bico enorme sobrevoam as copas das árvores!", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Animais de cores tão vivas que parecem pintados. Nunca os europeus haviam visto tamanha riqueza.", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ 'Desenhos da Fauna Local' adicionados ao diário de bordo!", "portrait": ""}
	]
}

func _ready() -> void:
	dialog_box.add_to_group("dialog_box")
	_setup_camera()
	if hud and hud.has_method("set_custom_objectives"):
		hud.set_custom_objectives(NOMES_OBJETIVOS)

func _setup_camera() -> void:
	await get_tree().process_frame
	var cam := player.get_node_or_null("Camera2D")
	if not cam:
		return

	# Calcula os limites da camera com base no tamanho/posicao REAIS do
	# sprite de fundo (em vez de numeros fixos) - assim, se a imagem for
	# reposicionada ou redimensionada no editor, a camera nunca mostra
	# alem da area realmente desenhada (evita a "faixa cinza").
	var background: Sprite2D = get_node_or_null("Fundo/Background")
	if background and background.texture:
		var tex_size: Vector2 = background.texture.get_size()
		var half_size: Vector2 = (tex_size * background.scale) / 2.0
		var center: Vector2 = background.global_position
		cam.limit_left   = int(center.x - half_size.x)
		cam.limit_top    = int(center.y - half_size.y)
		cam.limit_right  = int(center.x + half_size.x)
		cam.limit_bottom = int(center.y + half_size.y)
	else:
		# Reserva (fallback) caso o fundo nao seja encontrado.
		cam.limit_left   = 0
		cam.limit_top    = 0
		cam.limit_right  = 1152
		cam.limit_bottom = 550

	cam.position_smoothing_enabled = true

func _on_morro_interact() -> void:
	_registrar("morro")

func _on_floresta_interact() -> void:
	_registrar("floresta")

func _on_fauna_interact() -> void:
	_registrar("fauna")

func _registrar(item_id: String) -> void:
	if item_id in itens_coletados:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([
			{"speaker": "Cartógrafo", "text": "Já registrei isso no diário.", "portrait": ""}
		])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	itens_coletados.append(item_id)
	registros_feitos += 1
	if hud and hud.has_method("update_custom_objective"):
		hud.update_custom_objective(item_id)

	_mostrar_polaroid(item_id)
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct(ANOTACOES[item_id])
	await dialog_box.dialog_finished
	_esconder_polaroid()
	player.set_state(player.State.EXPLORING)

	if registros_feitos >= 3:
		await get_tree().create_timer(0.5).timeout
		_completar()

func _mostrar_polaroid(item_id: String) -> void:
	if not POLAROIDS.has(item_id):
		return
	polaroid_rect.texture = POLAROIDS[item_id]
	polaroid_dim.visible = true
	polaroid_rect.visible = true

func _esconder_polaroid() -> void:
	polaroid_dim.visible = false
	polaroid_rect.visible = false

func _completar() -> void:
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "Diário de bordo completo! Três registros feitos: a costa, a floresta e a fauna.", "portrait": ""},
		{"speaker": "Narrador", "text": "Pero Vaz de Caminha escreveria mais tarde: 'A terra é de muitos bons ares... águas são muitas, infinitas.'", "portrait": ""}
	])
	await dialog_box.dialog_finished
	GameManager.complete_objective(5, "explorar_costa")
	SceneManager.change_scene("res://scenes/levels/fase5/fase5_brasil.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)
		get_viewport().set_input_as_handled()
