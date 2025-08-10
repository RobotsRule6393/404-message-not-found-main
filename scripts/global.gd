extends Node

var speed = 350.0
var jumpVelocity = -550.0
var actions = [null,null,null,null,null]
var currentScene = 1
var spawnPoint = Vector2(0, 0)
var isDead = false
var inPhase = false
var phaseEndPosition = Vector2(0,0)
var phaseStartPosition = Vector2(0,0)
var jumps = 0
var boostCharges = 50
var playerAnimation = "default"
var moving = false

func _process(_delta):
	pass

func addAction(input):
	actions.append(input)
	actions.remove_at(0)
	#print("Added: ", Input)
	#print(actions)

func changeScene(scene):
	match scene:
		1:
			get_tree().change_scene_to_packed(preload("res://scenes/sceneOne.tscn"))
			currentScene = 1
		2:
			get_tree().change_scene_to_packed(preload("res://scenes/sceneTwo.tscn"))
			currentScene = 2
		3:
			get_tree().change_scene_to_packed(preload("res://scenes/sceneWin.tscn"))
			currentScene = 3

func death(deathCause, deadObject, canRespawn, waitTime):
	if not isDead and not inPhase:
		isDead = true
		playerAnimation = "death"
		Global.moving = true
		print("Died to ", deathCause, " at ", deadObject.global_position)
		
		if canRespawn:
			for i in range(2, 0, -1):
				await get_tree().create_timer(1).timeout
			deadObject.visible = false
			playerAnimation = "default"
			
			print("Respawning...")
			for i in range(waitTime * 2 - 2, 0, -1):
				await get_tree().create_timer(1).timeout
				print(i)
			deadObject.global_position = spawnPoint
			deadObject.visible = true
			
			await get_tree().create_timer(1).timeout
			print("Alive")
			isDead = false
		else:
			queue_free()
			print(deadObject, " removed.")

func phase(global_position, playerCollision, playerCrouchCollision):
	if not Global.isDead:
		if not Global.inPhase: #Toggles phase on
			Global.phaseStartPosition = global_position
			Global.inPhase = true
			playerCollision.disabled = true
			playerCrouchCollision.disabled = true
			Global.speed = Global.speed * 5
			Global.jumpVelocity = Global.jumpVelocity * 2
			print("Enabled phasing")
		else:#Toggles phase off
			await get_tree().create_timer(0.5).timeout
			if Input.is_action_pressed("hacks"):
				global_position = Global.phaseStartPosition
			
			Global.phaseEndPosition = global_position
			playerCrouchCollision.disabled = false
			Global.inPhase = false
			Global.speed = Global.speed / 5
			Global.jumpVelocity = Global.jumpVelocity / 2
			print("Disabled phasing")
