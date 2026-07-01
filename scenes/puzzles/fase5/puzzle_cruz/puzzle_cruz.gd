extends Node2D

var tronco_feito: bool = false
var corda_feita: bool = false
var alinhado: bool = false

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox

func _ready() -> void:
	dialog_box.add_to_group("dialog_box")

	await get_tree().create_timer(0.5).timeout
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "Era necessário erguer uma cruz para marcar a posse da terra em nome de Portugal.", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Precisamos carregar os troncos, amarrar as cordas e alinhar a cruz com o sol nascente.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

func _on_tronco_interact() -> void:
	if tronco_feito:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "Os troncos já estão no lugar.", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	tronco_feito = true
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Cartógrafo", "text": "Carregamos dois grandes troncos de madeira da floresta até a praia.", "portrait": ""},
		{"speaker": "Narrador", "text": "A cruz era um símbolo cristão e também de posse territorial. Erguê-la significava declarar a terra como domínio português.", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ Troncos posicionados!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)
	_verificar_conclusao()

func _on_corda_interact() -> void:
	if not tronco_feito:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "Primeiro precisamos carregar os troncos.", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	if corda_feita:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "As cordas já estão amarradas.", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	corda_feita = true
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Cartógrafo", "text": "Amarramos os troncos com cordas resistentes formando uma grande cruz.", "portrait": ""},
		{"speaker": "Narrador", "text": "Pero Vaz de Caminha registrou em sua carta que a cerimônia foi realizada com toda a tripulação presente.", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ Cordas amarradas!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)
	_verificar_conclusao()

func _on_alinhar_interact() -> void:
	if not corda_feita:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "Precisamos amarrar as cordas antes de erguer a cruz.", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	if alinhado:
		return

	alinhado = true
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Cartógrafo", "text": "Erguemos a cruz voltada ao sol nascente, no leste — direção de onde viemos.", "portrait": ""},
		{"speaker": "Narrador", "text": "A orientação da cruz ao leste tinha significado religioso: o sol nascente simbolizava Cristo e a esperança.", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ Cruz alinhada e erguida!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)
	_verificar_conclusao()

func _verificar_conclusao() -> void:
	if tronco_feito and corda_feita and alinhado:
		await get_tree().create_timer(0.5).timeout
		_completar()

func _completar() -> void:
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "A cruz foi erguida na praia. Toda a tripulação se ajoelhou diante dela.", "portrait": ""},
		{"speaker": "Narrador", "text": "Pero Vaz de Caminha escreveu ao Rei Dom Manuel I descrevendo cada detalhe deste momento histórico.", "portrait": ""},
		{"speaker": "Narrador", "text": "Esta carta, enviada em 1500, é considerada o primeiro documento escrito sobre o Brasil.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	GameManager.complete_objective(5, "puzzle_cruz")
	SceneManager.change_scene("res://scenes/levels/fase5/fase5_brasil.tscn")
