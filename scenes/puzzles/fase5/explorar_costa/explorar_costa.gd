extends Node2D

var registros_feitos: int = 0
var itens_coletados: Array[String] = []

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox

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

	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct(ANOTACOES[item_id])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

	if registros_feitos >= 3:
		await get_tree().create_timer(0.5).timeout
		_completar()

func _completar() -> void:
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "Diário de bordo completo! Três registros feitos: a costa, a floresta e a fauna.", "portrait": ""},
		{"speaker": "Narrador", "text": "Pero Vaz de Caminha escreveria mais tarde: 'A terra é de muitos bons ares... águas são muitas, infinitas.'", "portrait": ""}
	])
	await dialog_box.dialog_finished
	GameManager.complete_objective(5, "explorar_costa")
	SceneManager.change_scene("res://scenes/levels/fase5/fase5_brasil.tscn")
