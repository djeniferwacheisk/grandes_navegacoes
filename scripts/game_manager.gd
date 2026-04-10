extends Node
#---------------#
#	Fase2 		#
#---------------#

var fragmentos_coletados = 0
var objetivo_atual = 1

func coletar_fragmento():
	fragmentos_coletados += 1
	print("Fragmentos:", fragmentos_coletados)

	if fragmentos_coletados == 3:
		liberar_escambo()

func liberar_escambo():
	print("Objetivo novo: Fazer escambo")
	objetivo_atual = 2
	$EscamboScene.visible = true

func escambo_completo():
	objetivo_atual = 3
	mostrar_puzzle()

func puzzle_completo():
	finalizar_fase()

func mostrar_puzzle():
	$PuzzleScene.visible = true

func finalizar_fase():
	print("Cutscene iniciando")

	mostrar_cutscene()

func mostrar_cutscene():

	print("Se eles conseguiram, nós também conseguiremos. Avante!")
