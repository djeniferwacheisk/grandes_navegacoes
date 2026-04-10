extends Control

var pecas_corretas = 0


func peca_colocada():

	pecas_corretas += 1

	if pecas_corretas == 3:
		puzzle_resolvido()


func puzzle_resolvido():

	print("Mapa reconstruído")

	GameManager.puzzle_completo()
