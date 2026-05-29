## hud_fase4.gd
## HUD da Fase 4 — Rumo às Índias
## Exibe: recursos (água/comida/moral), objetivos, direção do vento

extends CanvasLayer

# Barras de recursos
@onready var barra_agua: ProgressBar = $Recursos/BarraAgua
@onready var barra_comida: ProgressBar = $Recursos/BarraComida
@onready var barra_moral: ProgressBar = $Recursos/BarraMoral
@onready var label_agua: Label = $Recursos/LabelAgua
@onready var label_comida: Label = $Recursos/LabelComida
@onready var label_moral: Label = $Recursos/LabelMoral

# Objetivos
@onready var objetivo_list: VBoxContainer = $Objetivos/Panel/Lista
@onready var label_vento: Label = $InfoVento/LabelVento
@onready var label_aviso: Label = $LabelAviso

var _objective_labels: Dictionary = {}

const OBJETIVOS := {
	"tripulacao_viva":  "[ ] Manter tripulação viva",
	"ventos_indico":    "[ ] Atravessar os ventos do Índico",
	"carta_navegacao":  "[ ] Coletar Carta de Navegação Árabe",
	"mercado_calecute": "[ ] Negociar em Calecute",
}


func _ready() -> void:
	GameManager.objective_completed.connect(_on_objective_completed)
	_setup_objetivos()
	_setup_barras()
	label_aviso.text = ""
	label_aviso.visible = false


func _setup_barras() -> void:
	barra_agua.max_value  = 100
	barra_comida.max_value = 100
	barra_moral.max_value  = 100
	barra_agua.value  = 100
	barra_comida.value = 100
	barra_moral.value  = 100


func _setup_objetivos() -> void:
	for child in objetivo_list.get_children():
		child.queue_free()

	for key in OBJETIVOS:
		var lbl := Label.new()
		lbl.add_theme_font_size_override("font_size", 7)
		var completo: bool = GameManager.is_objective_complete(4, key)
		lbl.text = ("[X] " if completo else "[ ] ") + OBJETIVOS[key].substr(4)
		objetivo_list.add_child(lbl)
		_objective_labels[key] = lbl


func _process(_delta: float) -> void:
	# Atualizar direção do vento no HUD
	if label_vento:
		var dir := GlobalWind.wind_direction
		label_vento.text = "Vento: %.0f°  |  Força: %.1f" % [dir, GlobalWind.wind_strength]


func atualizar_recurso(recurso: String, valor: float) -> void:
	match recurso:
		"water":
			barra_agua.value = valor
			_colorir_barra(barra_agua, valor)
		"food":
			barra_comida.value = valor
			_colorir_barra(barra_comida, valor)
		"morale":
			barra_moral.value = valor
			_colorir_barra(barra_moral, valor)


func _colorir_barra(barra: ProgressBar, valor: float) -> void:
	if valor < 20:
		barra.modulate = Color.RED
	elif valor < 40:
		barra.modulate = Color.YELLOW
	else:
		barra.modulate = Color.WHITE


func mostrar_aviso(texto: String, duracao: float = 3.0) -> void:
	label_aviso.text = texto
	label_aviso.visible = true
	await get_tree().create_timer(duracao).timeout
	label_aviso.visible = false


func _on_objective_completed(phase: int, objective: String) -> void:
	if phase != 4:
		return
	if _objective_labels.has(objective):
		var lbl: Label = _objective_labels[objective]
		lbl.text = lbl.text.replace("[ ] ", "[X] ")
		var tween := create_tween()
		tween.tween_property(lbl, "modulate", Color.YELLOW, 0.2)
		tween.tween_property(lbl, "modulate", Color.WHITE, 0.4)
