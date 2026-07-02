extends Control

## Tela de transicao entre fases. Generica para as 5 fases: mostra a
## mensagem de conclusao da fase que acabou de terminar
## (GameManager.last_completed_phase) e avisa qual e a proxima fase antes
## de o jogador continuar.

const PHASE_INFO := {
	1: {
		"title": "Escola de Sagres",
		"map_label": "Costa de Portugal",
		"message": "Você completou seu treinamento na Escola de Sagres!",
	},
	2: {
		"title": "Periplo Africano",
		"map_label": "Costa da África",
		"message": "A costa africana foi explorada e as primeiras trocas com os povos locais foram feitas!",
	},
	3: {
		"title": "Cabo das Tormentas",
		"map_label": "Cabo da Boa Esperança",
		"message": "A frota resistiu às tormentas e contornou o Cabo da Boa Esperança!",
	},
	4: {
		"title": "Rumo às Índias",
		"map_label": "Calecute, Índia",
		"message": "Em 1498, a frota chegou às Índias! O caminho das especiarias está aberto.",
	},
	5: {
		"title": "Chegada ao Brasil",
		"map_label": "Terra de Santa Cruz",
		"message": "Em 22 de abril de 1500, a esquadra de Cabral avistou e tomou posse de uma nova terra.",
	},
}

const TOTAL_FASES := 5

@onready var text_label: Label = $TextLabel
@onready var next_phase_label: Label = $NextPhaseLabel
@onready var map_reveal: ColorRect = $MapReveal
@onready var continue_button: Button = $ContinueButton


func _ready() -> void:
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue)
	map_reveal.modulate.a = 0.0
	next_phase_label.modulate.a = 0.0

	var phase: int = GameManager.last_completed_phase
	if phase <= 0:
		phase = 1
	var info: Dictionary = PHASE_INFO.get(phase, PHASE_INFO[1])

	# Etapa 1: mensagem de conclusao da fase (efeito de maquina de escrever)
	text_label.text = ""
	var full_text: String = "Fase %d concluída: %s!\n\n%s" % [phase, info["title"], info["message"]]
	for i in full_text.length():
		text_label.text = full_text.substr(0, i + 1)
		await get_tree().create_timer(0.03).timeout

	# Etapa 2: revela o pedaco do mapa referente a fase concluida
	await get_tree().create_timer(0.5).timeout
	var tween := create_tween()
	tween.tween_property(map_reveal, "modulate:a", 1.0, 1.5)
	await tween.finished

	# Etapa 3: avisa qual sera a proxima fase (ou que o jogo terminou)
	await get_tree().create_timer(0.3).timeout
	if phase < TOTAL_FASES:
		var next_info: Dictionary = PHASE_INFO.get(phase + 1, {})
		var next_title: String = next_info.get("title", "")
		next_phase_label.text = "A próxima fase vai começar: Fase %d — %s" % [phase + 1, next_title]
	else:
		next_phase_label.text = "Parabéns! Você completou As Grandes Navegações!"
	var tween2 := create_tween()
	tween2.tween_property(next_phase_label, "modulate:a", 1.0, 0.8)
	await tween2.finished

	continue_button.visible = true
	continue_button.grab_focus()


func _on_continue() -> void:
	var phase: int = GameManager.last_completed_phase
	if phase >= TOTAL_FASES:
		# Fim de jogo: nao ha proxima fase, volta ao menu principal.
		SceneManager.change_scene("res://scenes/menus/title_screen.tscn")
	else:
		# GameManager.current_phase ja foi avancado em finish_phase(),
		# entao main.tscn vai carregar automaticamente a proxima fase.
		SceneManager.change_scene("res://scenes/main/main.tscn")
