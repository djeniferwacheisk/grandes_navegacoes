## Area_MercadoCalecute.gd
## Mercado de Calecute — cena BASE de exploração das 3 tendas.
## Player anda, interage com cada tenda → muda para a cena específica da balança.
## Cada balança, ao concluir, salva o flag no GameManager e volta para esta cena.

extends Node2D

var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

# Caminhos das 3 cenas de balança (cada uma com background e items próprios)
const BALANCA_FERRAMENTAS := "res://scenes/puzzles/fase4/BalancaFerramentas.tscn"
const BALANCA_TECIDOS     := "res://scenes/puzzles/fase4/BalancaTecidos.tscn"
const BALANCA_VINHOS      := "res://scenes/puzzles/fase4/BalancaVinhos.tscn"

signal objetivo_concluido()

@onready var player:          CharacterBody2D = $Player
@onready var dialog_box                       = $DialogBox
@onready var label_progresso: Label = $HUD/LabelProgresso


func _ready() -> void:
	add_to_group("area_fase4")
	_setup_camera()
	_sincronizar_com_gamemanager()

	# Se já tinha completado o objetivo, sai direto (segurança contra reentrada)
	if GameManager.is_objective_complete(4, "mercado_calecute"):
		_atualizar_progresso()
		return

	_atualizar_progresso()

	# Se acabou de voltar de uma balança e completou todas as 3, finaliza
	if _todas_concluidas():
		await get_tree().create_timer(0.6).timeout
		_finalizar()


func _sincronizar_com_gamemanager() -> void:
	pass  # Status visual das tendas gerenciado pelo LabelProgresso


func _setup_camera() -> void:

	await get_tree().process_frame
	var cam := player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_left   = 0
		cam.limit_top    = 0
		cam.limit_right  = 640
		cam.limit_bottom = 360
		cam.position_smoothing_enabled = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)



func _on_tenda_ferramentas() -> void:
	if GameManager.get_phase_flag(4, "troca_ferramentas", false):
		_falar("Ibn Rashid", "Já fizemos nossa troca. Que Allah te proteja na viagem!")
		return
	SceneManager.change_scene(BALANCA_FERRAMENTAS)


func _on_tenda_tecidos() -> void:
	if GameManager.get_phase_flag(4, "troca_tecidos", false):
		_falar("Lakshmi", "Os tecidos já estão no navio. Boa viagem!")
		return
	SceneManager.change_scene(BALANCA_TECIDOS)


func _on_tenda_vinhos() -> void:
	if GameManager.get_phase_flag(4, "troca_vinhos", false):
		_falar("Ravi", "Os vinhos já foram embarcados. Sucesso na viagem!")
		return
	SceneManager.change_scene(BALANCA_VINHOS)

func _todas_concluidas() -> bool:
	return (
		GameManager.get_phase_flag(4, "troca_ferramentas", false)
		and GameManager.get_phase_flag(4, "troca_tecidos", false)
		and GameManager.get_phase_flag(4, "troca_vinhos", false)
	)

func _atualizar_progresso() -> void:
	var feitas := 0
	if GameManager.get_phase_flag(4, "troca_ferramentas", false): feitas += 1
	if GameManager.get_phase_flag(4, "troca_tecidos",     false): feitas += 1
	if GameManager.get_phase_flag(4, "troca_vinhos",      false): feitas += 1
	label_progresso.text = "Trocas: %d / 3" % feitas


func _finalizar() -> void:
	if GameManager.is_objective_complete(4, "mercado_calecute"):
		return 
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Vasco da Gama",
		 "text": "Negociamos com honra e respeito. As especiarias estão a bordo!",
		 "portrait": ""},
		{"speaker": "Comerciante Local",
		 "text": "Boas trocas criam boas amizades. Voltem sempre, navegadores!",
		 "portrait": ""},
	])
	await dialog_box.dialog_finished
	GameManager.add_item("Sacos de Especiarias", "Pimenta, cravo e canela das Índias")
	GameManager.complete_objective(4, "mercado_calecute")
	GameManager.save_game()
	objetivo_concluido.emit()

	# Isso e o que faltava: a cena nunca voltava para o mapa principal
	# depois de completar as 3 trocas - o GameManager.complete_objective()
	# so avisa quem estiver ESCUTANDO o sinal global naquele momento, e
	# o script do mapa principal (Level4_RumoAsIndias.gd) nao esta
	# carregado enquanto o jogador esta dentro do mercado, entao
	# ninguem reagia. Precisa voltar explicitamente pra cena do mapa.
	await get_tree().create_timer(0.5).timeout
	SceneManager.change_scene("res://scenes/levels/fase4/Level4_RumoAsIndias.tscn")


func _falar(personagem: String, texto: String) -> void:
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([{"speaker": personagem, "text": texto, "portrait": ""}])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)
