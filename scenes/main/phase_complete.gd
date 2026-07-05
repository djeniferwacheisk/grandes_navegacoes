extends Control


const PHASE_INFO := {
	1: {
		"title": "Escola de Sagres",
		"message": "Parabéns, jovem cartógrafo! Você concluiu a fase Escola de Sagres.\n\nAqui aprendemos a usar a bússola, observar os astros com o astrolábio, entender os ventos e preparar a caravela para enfrentar o mar aberto. Esses conhecimentos foram essenciais para que os navegadores portugueses se aventurassem por oceanos desconhecidos.\n\nGuarde bem essas informações: elas serão importantes nas próximas jornadas.",
	},
	3: {
		"title": "Cabo das Tormentas",
		"message": "Parabéns, jovem cartógrafo! Você concluiu a fase Cabo das Tormentas.\n\nAqui enfrentamos tempestades, ondas perigosas e uma das rotas mais temidas pelos navegadores. Ao contornar esse cabo, mais tarde chamado de Cabo da Boa Esperança, Bartolomeu Dias abriu um novo caminho marítimo entre o Oceano Atlântico e o Oceano Índico.\n\nGuarde bem essa conquista: ela mudou o futuro das navegações portuguesas.",
	},
	4: {
		"title": "Rumo às Índias",
		"message": "Parabéns, jovem cartógrafo! Você concluiu a fase Rumo às Índias.\n\nAqui aprendemos a cuidar da tripulação durante uma longa viagem e a negociar mercadorias em Calecute. Ferramentas, tecidos e vinhos eram trocados por especiarias valiosas, mostrando a importância do comércio entre diferentes povos.\n\nEm 1498, Vasco da Gama completou essa rota, ligando Portugal diretamente às riquezas do Oriente pelo mar.\n\nGuarde bem essas informações: o comércio foi um dos grandes motores das Grandes Navegações.",
	},
	5: {
		"title": "Chegada ao Brasil",
		"message": "Parabéns, jovem cartógrafo! Você concluiu a fase Chegada ao Brasil.\n\nAqui exploramos uma nova costa, observamos suas florestas, sua fauna colorida e o valioso pau-brasil. Também aprendemos sobre o primeiro contato entre portugueses e povos Tupiniquins, marcado por gestos, presentes e tentativas de comunicação entre culturas diferentes.\n\nPor fim, vimos o significado de erguer uma cruz em nome de Portugal, um gesto simbólico usado para marcar a posse da terra.\n\nEm 1500, a chegada da expedição de Pedro Álvares Cabral marcou o início de um novo capítulo da história do Brasil.\n\nSua jornada pelas Grandes Navegações chegou ao fim. Você navegou por mares desconhecidos, enfrentou desafios, conheceu novos caminhos e acompanhou acontecimentos que transformaram a história. Parabéns pela aventura, jovem cartógrafo!",
	},
}

const TOTAL_FASES := 5

@onready var dim: ColorRect = $Dim
@onready var pergaminho: TextureRect = $Pergaminho
@onready var text_label: Label = $Pergaminho/TextLabel


func _ready() -> void:
	dim.modulate.a = 0.0
	pergaminho.modulate.a = 0.0
	text_label.text = ""

	var phase: int = GameManager.last_completed_phase
	if phase <= 0:
		phase = 1
	var info: Dictionary = PHASE_INFO.get(phase, PHASE_INFO[1])

	# Etapa 1: o pergaminho aparece (fade-in)
	var tween_in := create_tween()
	tween_in.tween_property(dim, "modulate:a", 1.0, 0.6)
	tween_in.parallel().tween_property(pergaminho, "modulate:a", 1.0, 0.6)
	await tween_in.finished

	# Etapa 2: mensagem de conclusao da fase (efeito de maquina de escrever)
	await get_tree().create_timer(0.2).timeout
	var full_text: String = "" % [phase, info["title"], info["message"]]
	for i in full_text.length():
		text_label.text = full_text.substr(0, i + 1)
		await get_tree().create_timer(0.03).timeout

	# Etapa 3: uma pausa pro jogador ler, depois troca de fase sozinho
	await get_tree().create_timer(2.5).timeout

	var tween_out := create_tween()
	tween_out.tween_property(dim, "modulate:a", 0.0, 0.6)
	tween_out.parallel().tween_property(pergaminho, "modulate:a", 0.0, 0.6)
	await tween_out.finished

	if phase >= TOTAL_FASES:
		# Fim de jogo: nao ha proxima fase, volta ao menu principal.
		SceneManager.change_scene("res://scenes/menus/title_screen.tscn")
	else:

		SceneManager.change_scene("res://scenes/main/main.tscn")
