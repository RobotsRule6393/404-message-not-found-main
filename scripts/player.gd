extends CharacterBody2D

func _physics_process(delta):
	if not Global.isDead:
		if not is_on_floor() and not Global.inPhase or (Input.is_action_pressed("crouch") and Global.inPhase):
			velocity += get_gravity() * delta
		
		if  velocity.y > 20:
			Global.playerAnimation = "falling"
			Global.moving = true
			
		if velocity.y < 0:
			Global.playerAnimation = "jumping"
			Global.moving = true
	
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
				
				Global.playerAnimation = "crouching"
				Global.moving = true
		
		elif not Global.inPhase:
			$playerCollision.disabled = false
			$playerCrouchCollision.disabled = true
		
		var direction = Input.get_axis("walkLeft", "walkRight")
		if direction:
			velocity.x = direction * Global.speed
		else:
			velocity.x = move_toward(velocity.x, 0, Global.speed)
		
		if direction > 0 and is_on_floor():
			Global.playerAnimation = "walking"
			Global.moving = true
		elif direction < 0 and is_on_floor():
			Global.playerAnimation = "walking"
			Global.moving = true
		
	else:
		velocity = Vector2(0,0)
	
	move_and_slide()


func _process(_delta):
	$playerSprite.play(Global.playerAnimation)#change once you have all animations
	
	if position.y > 500: #Death to void
		Global.death("void", self, true, 4, true)
	
	if Input.is_action_just_pressed("hacks") or (Input.is_action_just_pressed("alt") and Input.is_action_pressed("f4")): #Phasing hacks
		Global.phase(global_position, $playerCollision, $playerCrouchCollision)
	
	if is_on_floor(): #Resets jumps if on floor
		Global.jumps = 0
		
	if not Global.moving and not Global.isDead:
		Global.playerAnimation = "default"

	else:
		Global.moving = false
	print(Global.playerAnimation)

func _on_area_2d_body_entered(body: Node2D):
	if body.name == "tileMap":
		Global.death("water", self, true, 3, true)
