extends Node2D

# ── Sinais ────────────────────────────────────────────────────────────────────
signal minigame_completo(sucesso: bool)
var tex_mastro_solto   = preload("res://assets/miniGame/Mastro_com_Vela_Solta.png")
var tex_mastro_firme   = preload("res://assets/miniGame/Mastro_com_Vela_Firme.png")
var tex_corda          = preload("res://assets/miniGame/Corda.png")
var tex_leme           = preload("res://assets/miniGame/Leme_do_Navio.png")
var tex_navio_inclinado = preload("res://assets/miniGame/Navio_Inclinado.png")
var tex_vela_rasgada   = preload("res://assets/miniGame/Vela_Rasgada.png")
var tex_vela_remendada = preload("res://assets/miniGame/Vela_Remendada.png")

# ── Referências ───────────────────────────────────────────────────────────────
@onready var titulo_fase: Label = $TituloFase
@onready var contexto: Label = $Contexto
@onready var instrucao: Label = $Instrucao
@onready var barra_tempo: ProgressBar = $BarraTempo
@onready var area_jogo: Control  = $Container
@onready var btn_avancar: Button = $BtnAvancar

# ── Dados das fases ───────────────────────────────────────────────────────────
var fases = [
	{
		"titulo": "Fase 1 — Puxar Cordas",
		"contexto": "As velas estão soltas! A tripulação precisa tensionar as cordas para manter o mastro firme contra o vento. Na época das grandes navegações, os marinheiros trabalhavam em equipe para controlar as velas manualmente.",
		"instrucao": "Segure ESPAÇO e solte quando a barra atingir a zona VERDE!",
		"tipo": "cordas",
		"fato": "Os navios portugueses usavam velas latinas e quadradas, que exigiam grande habilidade da tripulação para manobrar."
	},
	{
		"titulo": "Fase 2 — Remendar as Velas",
		"contexto": "A tempestade rasgou o velame! Os marujos trabalham em equipe seguindo comandos precisos para remendar as velas. A velocidade e coordenação eram essenciais para a sobrevivência.",
		"instrucao": "Aperte as teclas na ordem correta antes do tempo acabar!",
		"tipo": "qte",
		"fato": "As velas das caravelas eram feitas de linho ou algodão reforçado. Um velame rasgado podia condenar toda a tripulação."
	},
	{
		"titulo": "Fase 3 — Controlar o Leme",
		"contexto": "O vento quer virar o navio! O piloto precisa manter o leme equilibrado para que a caravela não capote nas ondas gigantes do Cabo das Tormentas.",
		"instrucao": "Use ← → para manter a agulha no centro!",
		"tipo": "equilibrio",
		"fato": "O Cabo das Tormentas recebia ventos de mais de 100 km/h. Bartolomeu Dias foi o primeiro europeu a navegar por essas águas em 1488."
	}
]

# ── Estado ────────────────────────────────────────────────────────────────────
var fase_atual: int = 0
var em_contexto: bool = true
var em_jogo: bool = false
var tempo_restante: float = 0.0
var acertos: int = 0
var erros: int = 0

# ── QTE ───────────────────────────────────────────────────────────────────────
var sequencia_qte: Array = ["ui_left", "ui_right", "ui_up", "ui_left", "ui_up"]
var indice_qte: int = 0
var labels_qte: Array = []

# ── Cordas ────────────────────────────────────────────────────────────────────
var posicao_barra: float = 0.0
var direcao_barra: float = 1.0
var velocidade_barra: float = 80.0
var zona_verde_min: float = 40.0
var zona_verde_max: float = 60.0
var barra_cordas: ProgressBar = null

# ── Equilíbrio ────────────────────────────────────────────────────────────────
var posicao_agulha: float = 50.0
var deriva_agulha: float = 0.0
var barra_equilibrio: ProgressBar = null


func _ready() -> void:
	print("MINIGAME READY!")
	btn_avancar.pressed.connect(_on_btn_avancar)
	# Força tamanho da tela
	$AreaJogo.size = get_viewport_rect().size
	$Fundo.size = get_viewport_rect().size
	mostrar()


func mostrar() -> void:
	print("Minigame mostrar chamado!")
	show()
	fase_atual = 0
	_mostrar_contexto()

func _mostrar_contexto() -> void:
	em_contexto = true
	em_jogo = false
	var fase = fases[fase_atual]
	titulo_fase.text = fase["titulo"]
	contexto.text = fase["contexto"]
	instrucao.text = fase["instrucao"]
	btn_avancar.text = "Entendido — Vamos lá!"
	btn_avancar.visible = true
	barra_tempo.visible = false
	_limpar_area_jogo()


func _on_btn_avancar() -> void:
	if em_contexto:
		_iniciar_jogo()
	else:
		_proxima_fase()


func _iniciar_jogo() -> void:
	em_contexto = false
	em_jogo = true
	btn_avancar.visible = false
	barra_tempo.visible = true
	tempo_restante = 100.0
	var fase = fases[fase_atual]
	match fase["tipo"]:
		"cordas":   _setup_cordas()
		"qte":      _setup_qte()
		"equilibrio": _setup_equilibrio()


func _process(delta: float) -> void:
	if not em_jogo:
		return
	tempo_restante -= delta * 20.0
	barra_tempo.value = tempo_restante
	if tempo_restante <= 0:
		_fase_falhou()
		return
	var tipo = fases[fase_atual]["tipo"]
	match tipo:
		"cordas":     _update_cordas(delta)
		"equilibrio": _update_equilibrio(delta)


func _input(event: InputEvent) -> void:
	if not em_jogo:
		return
	var tipo = fases[fase_atual]["tipo"]
	if tipo == "cordas" and event.is_action_released("ui_accept"):
		_checar_corda()
	elif tipo == "qte":
		_checar_qte(event)
	elif tipo == "equilibrio":
		_input_equilibrio(event)


# ── CORDAS ────────────────────────────────────────────────────────────────────
func _setup_cordas() -> void:
	barra_cordas = ProgressBar.new()
	barra_cordas.min_value = 0
	barra_cordas.max_value = 100
	barra_cordas.value = 0
	barra_cordas.size = Vector2(300, 40)
	barra_cordas.position = Vector2(100, 100)
	area_jogo.add_child(barra_cordas)
	posicao_barra = 0.0
	direcao_barra = 1.0
	acertos = 0


func _update_cordas(delta: float) -> void:
	posicao_barra += direcao_barra * velocidade_barra * delta
	if posicao_barra >= 100:
		posicao_barra = 100
		direcao_barra = -1.0
	elif posicao_barra <= 0:
		posicao_barra = 0
		direcao_barra = 1.0
	if barra_cordas:
		barra_cordas.value = posicao_barra
	# Muda cor conforme posição
	if posicao_barra >= zona_verde_min and posicao_barra <= zona_verde_max:
		instrucao.text = "AGORA! Solte o ESPAÇO!"
		instrucao.modulate = Color(0, 1, 0)
	else:
		instrucao.text = "Segure ESPAÇO e solte na zona verde!"
		instrucao.modulate = Color(1, 1, 1)


func _checar_corda() -> void:
	if posicao_barra >= zona_verde_min and posicao_barra <= zona_verde_max:
		acertos += 1
		instrucao.text = "Perfeito! (%d/3)" % acertos
		if acertos >= 3:
			_fase_completa()
	else:
		erros += 1
		instrucao.text = "Errou! Tente novamente."


# ── QTE ───────────────────────────────────────────────────────────────────────
func _setup_qte() -> void:
	indice_qte = 0
	acertos = 0
	sequencia_qte.shuffle()
	_mostrar_qte()


func _mostrar_qte() -> void:
	_limpar_area_jogo()
	var nomes = {"ui_left": "←", "ui_right": "→", "ui_up": "↑", "ui_down": "↓"}
	for i in sequencia_qte.size():
		var label = Label.new()
		label.text = nomes.get(sequencia_qte[i], "?")
		label.position = Vector2(i * 60 + 20, 80)
		label.add_theme_font_size_override("font_size", 32)
		if i == indice_qte:
			label.modulate = Color(1, 1, 0)
		elif i < indice_qte:
			label.modulate = Color(0, 1, 0)
		else:
			label.modulate = Color(1, 1, 1)
		area_jogo.add_child(label)


func _checar_qte(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	var acao_esperada = sequencia_qte[indice_qte]
	if event.is_action(acao_esperada):
		indice_qte += 1
		_mostrar_qte()
		if indice_qte >= sequencia_qte.size():
			_fase_completa()
	else:
		erros += 1
		instrucao.text = "Errou! Continue..."
		instrucao.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.5).timeout
		instrucao.modulate = Color(1, 1, 1)


# ── EQUILÍBRIO ────────────────────────────────────────────────────────────────
func _setup_equilibrio() -> void:
	barra_equilibrio = ProgressBar.new()
	barra_equilibrio.min_value = 0
	barra_equilibrio.max_value = 100
	barra_equilibrio.value = 50
	barra_equilibrio.size = Vector2(300, 40)
	barra_equilibrio.position = Vector2(100, 100)
	area_jogo.add_child(barra_equilibrio)
	posicao_agulha = 50.0
	deriva_agulha = randf_range(-30, 30)
	acertos = 0


func _update_equilibrio(delta: float) -> void:
	posicao_agulha += deriva_agulha * delta
	posicao_agulha = clamp(posicao_agulha, 0, 100)
	if barra_equilibrio:
		barra_equilibrio.value = posicao_agulha
	# Muda deriva aleatoriamente
	deriva_agulha += randf_range(-20, 20) * delta
	deriva_agulha = clamp(deriva_agulha, -60, 60)
	# Conta tempo no centro
	if posicao_agulha >= 35 and posicao_agulha <= 65:
		acertos += delta
		instrucao.text = "Ótimo! Mantenha o equilíbrio! (%.1fs/5s)" % acertos
		instrucao.modulate = Color(0, 1, 0)
		if acertos >= 5.0:
			_fase_completa()
	else:
		instrucao.text = "Use ← → para centralizar!"
		instrucao.modulate = Color(1, 1, 1)


func _input_equilibrio(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		deriva_agulha -= 40.0
	elif event.is_action_pressed("ui_right"):
		deriva_agulha += 40.0


# ── CONTROLE DE FASES ─────────────────────────────────────────────────────────
func _fase_completa() -> void:
	em_jogo = false
	var fase = fases[fase_atual]
	contexto.text = "✓ " + fase["fato"]
	contexto.modulate = Color(0, 1, 0.5)
	instrucao.text = ""
	btn_avancar.visible = true
	if fase_atual >= fases.size() - 1:
		btn_avancar.text = "Concluir Reparo!"
	else:
		btn_avancar.text = "Próxima Tarefa →"


func _fase_falhou() -> void:
	em_jogo = false
	instrucao.text = "Tempo esgotado! Tente novamente."
	instrucao.modulate = Color(1, 0, 0)
	btn_avancar.text = "Tentar Novamente"
	btn_avancar.visible = true
	await get_tree().create_timer(0.5).timeout


func _proxima_fase() -> void:
	contexto.modulate = Color(1, 1, 1)
	instrucao.modulate = Color(1, 1, 1)
	if fase_atual >= fases.size() - 1:
		emit_signal("minigame_completo", true)
		hide()
	else:
		fase_atual += 1
		_mostrar_contexto()


func _limpar_area_jogo() -> void:
	for child in area_jogo.get_children():
		child.queue_free()
