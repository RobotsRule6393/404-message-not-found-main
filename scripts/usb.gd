extends CharacterBody2D

var direction = 1

func _on_usb_hitbox_body_entered(body: Node2D):
	#run usb ataching and stealing files 
	if body.name == "player":
		Global.death("usb", body, true, 2)

func _physics_process(_delta):
	if not is_on_floor():
		velocity += get_gravity()
	
	velocity.x = direction * Global.speed * 0.75
	
	if direction == 0 or is_on_wall():
		direction = randi_range(-1,1)
	
	if velocity.x:
		$portalSprite.flip_h = velocity.x < 0
	
	move_and_slide()
