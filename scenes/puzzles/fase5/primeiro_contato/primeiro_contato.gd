extends Node2D

var presente_dado: bool = false
var contato_feito: bool = false

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox

func _ready() -> void:
	dialog_box.add_to_group("dialog_box")

	await get_tree().create_timer(0.5).timeout
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "Na praia, um grupo de Tupiniquins observa os visitantes com curiosidade. Não há hostilidade — apenas espanto mútuo.", "portrait": ""},
		{"speaker": "Narrador", "text": "Ofereça um presente e depois se aproxime para o contato.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

func _on_presente_interact() -> void:
	if presente_dado:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([
			{"speaker": "Cartógrafo", "text": "Já oferecemos os presentes. Agora nos aproximemos deles.", "portrait": ""}
		])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	presente_dado = true
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Cartógrafo", "text": "Oferecemos espelhos e miçangas coloridas. Os Tupiniquins olham curiosos para os objetos brilhantes.", "portrait": ""},
		{"speaker": "Narrador", "text": "Oferecer presentes era uma forma de demonstrar intenções pacíficas no primeiro contato entre povos.", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ Presente oferecido! Agora aproxime-se dos Tupiniquins.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

func _on_contato_interact() -> void:
	if not presente_dado:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([
			{"speaker": "Cartógrafo", "text": "Devemos primeiro oferecer presentes antes de nos aproximar. É sinal de boa vontade.", "portrait": ""}
		])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	if contato_feito:
		return

	contato_feito = true
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Tupiniquim", "text": "...", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Eles nos observam com curiosidade. Um deles sorri e imita nossos gestos.", "portrait": ""},
		{"speaker": "Narrador", "text": "Os Tupiniquins eram o povo que habitava o litoral do que hoje é o Brasil. Viviam da pesca, caça e agricultura.", "portrait": ""},
		{"speaker": "Tupiniquim", "text": "...", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Um deles nos entrega um colar cerimonial. É um gesto de amizade e acolhimento.", "portrait": ""},
		{"speaker": "Narrador", "text": "Pero Vaz de Caminha descreveu este encontro: 'Eram pardos, todos nus, sem coisa alguma que lhes cobrisse suas vergonhas.'", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ 'Colar Cerimonial Tupiniquim' recebido — registro cultural, não item de poder.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	_completar()

func _completar() -> void:
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "O primeiro contato terminou em paz. Os Tupiniquins sorriram e acenaram ao partir.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)
	GameManager.complete_objective(5, "primeiro_contato")
	SceneManager.change_scene("res://scenes/levels/fase5/fase5_brasil.tscn")
