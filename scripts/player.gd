extends CharacterBody2D

func _physics_process(delta):
	if not is_on_floor() and not Global.inPhase or (Input.is_action_pressed("crouch") and Global.inPhase):
		velocity += get_gravity() * delta
	
	if not Global.isDead:
		if Input.is_action_just_pressed("jump") and Global.jumps <= 1:
			Global.jumps = Global.jumps + 1
			velocity.y = Global.jumpVelocity
		
		if Input.is_action_pressed("jump") and Global.inPhase:
			velocity.y = Global.jumpVelocity
		elif Global.inPhase:
			velocity.y = move_toward(velocity.y, 0, Global.speed)
		
		if Input.is_action_pressed("crouch"):
			velocity.y = - Global.jumpVelocity
			if not Global.inPhase:
				$playerCollision.disabled = true
				$playerCrouchCollision.disabled = false
		
		elif not Global.inPhase:
			$playerCollision.disabled = false
			$playerCrouchCollision.disabled = true
		
		var direction = Input.get_axis("walkLeft", "walkRight")
		if direction:
			velocity.x = direction * Global.speed
		else:
			velocity.x = move_toward(velocity.x, 0, Global.speed)
	else:
		velocity = Vector2(0,0)

	move_and_slide()


func _process(_delta):
	if position.y > 500: #Death to void
		Global.death("void", self, true, 2)
	
	if Input.is_action_just_pressed("hacks") or (Input.is_action_just_pressed("alt") and Input.is_action_pressed("f4")): #Phasing hacks
		Global.phase(global_position, $playerCollision, $playerCrouchCollision)
	
	if is_on_floor(): #Resets jumps if on floor
		Global.jumps = 0

func _on_area_2d_body_entered(body: Node2D):
	if body.name == "tileMap":
		Global.death("water", self, true, 2)
