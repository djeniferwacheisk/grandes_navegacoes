extends CharacterBody2D

const SPEED = 200.0

func _physics_process(delta):
	# 1. PEGAR A DIREÇÃO (FÍSICA)
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * SPEED
	
	# 2. EXECUTAR O MOVIMENTO
	move_and_slide()

	# 3. ATUALIZAR A IMAGEM (ANIMAÇÃO)
	if input_direction != Vector2.ZERO:
		# Se estiver se movendo, escolhe a animação baseada no eixo mais forte
		if abs(input_direction.x) > abs(input_direction.y):
			$AnimatedSprite2D.play("walk_side")
			$AnimatedSprite2D.flip_h = input_direction.x < 0
		else:
			if input_direction.y > 0:
				$AnimatedSprite2D.play("walk_down")
			else:
				$AnimatedSprite2D.play("walk_up")
	else:
		# Se estiver parado
		$AnimatedSprite2D.play("idle")
		
