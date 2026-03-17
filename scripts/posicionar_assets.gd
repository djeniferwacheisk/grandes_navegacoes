@tool
extends EditorScript

func _run() -> void:
	var scene_root = get_scene()
	var objetos = scene_root.get_node("Objetos")
	
	# Limpar filhos existentes
	for child in objetos.get_children():
		child.queue_free()
	
	# Mapa: Position(-130, -127), Scale(0.5, 0.5), imagem 2000x1173
	# Coordenadas em pixels do mapa original -> posicao no Godot:
	# godot_x = (orig_x * 0.5) + (-130)
	# godot_y = (orig_y * 0.5) + (-127)
	
	var assets = [
		# [nome_arquivo, orig_x, orig_y, scale]
		["Castelo",    1050, 180,  0.35],
		["templo",     310,  80,   0.4 ],
		["torre",      560,  200,  0.35],
		["casa1",      1300, 580,  0.4 ],
		["casa2",      1480, 620,  0.4 ],
		["casa3",      1600, 700,  0.4 ],
		["casa4",      1350, 720,  0.4 ],
		["caravela1",  1450, 280,  0.45],
		["barco1",     1650, 350,  0.4 ],
		["barco2",     1750, 420,  0.4 ],
		["astrolabio", 310,  30,   0.4 ],
		["estatua",    900,  420,  0.38],
		["arvores",    50,   350,  0.5 ],
		["arvore",     750,  480,  0.4 ],
		["arvore",     820,  520,  0.4 ],
		["muro1",      700,  350,  0.4 ],
		["muro2",      680,  440,  0.38],
		["muro3",      760,  400,  0.38],
		["muro4",      640,  380,  0.38],
		["muro5",      720,  460,  0.38],
		["pilar1",     950,  380,  0.38],
		["pilar2",     1000, 400,  0.38],
		["barril",     1150, 460,  0.38],
		["barril1",    1200, 480,  0.38],
		["caixa1",     1100, 450,  0.38],
		["poco",  1500, 780,  0.38],
	]
	
	for asset_data in assets:
		var nome = asset_data[0]
		var orig_x = asset_data[1]
		var orig_y = asset_data[2]
		var escala = asset_data[3]
		
		var godot_x = (orig_x * 0.5) + (-130)
		var godot_y = (orig_y * 0.5) + (-127)
		
		var sprite = Sprite2D.new()
		sprite.name = nome
		sprite.position = Vector2(godot_x, godot_y)
		sprite.scale = Vector2(escala, escala)
		sprite.centered = false
		
		var tex_path = "res://assets/mapa/" + nome + ".png"
		var tex = load(tex_path)
		if tex:
			sprite.texture = tex
			print("OK: ", nome)
		else:
			print("NAO ENCONTRADO: ", tex_path)
		
		objetos.add_child(sprite)
		sprite.owner = scene_root
	
	print("Concluido! ", assets.size(), " assets adicionados.")
