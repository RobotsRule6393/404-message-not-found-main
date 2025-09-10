extends Node

var speed = 350.0
var jumpVelocity = -550.0
var actions = [null,null,null,null,null]
var currentScene = 0
var spawnPoint = Vector2(0, 0)
var isDead = false
var inPhase = false
var phaseEndPosition = Vector2(0,0)
var phaseStartPosition = Vector2(0,0)
var jumps = 0
var boostCharges = 50
var playerAnimation = "default"
var moving = false
var hitFloor = true
var falling = false

var num_players = 8
var bus = "master"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.


func addAction(input):
	actions.append(input)
	actions.remove_at(0)
	#print("Added: ", Input)
	#print(actions)


func changeScene(scene):
	if not inPhase:
		match scene:
			1:
				get_tree().change_scene_to_packed(preload("res://scenes/levelOne.tscn"))
				currentScene = 1
			2:
				get_tree().change_scene_to_packed(preload("res://scenes/levelTwo.tscn"))
				currentScene = 2
			3:
				get_tree().change_scene_to_packed(preload("res://scenes/winLevel.tscn"))
				currentScene = 2


func death(deathCause, deadObject, canRespawn, waitTime, isPlayer):
	if isPlayer == true:
		playerAnimation = "death"
		moving = true
		play("res://sprites/reliable-safe-327618.mp3")
	
	if not isDead and not inPhase:
		isDead = true
		print("Died to ", deathCause, " at ", deadObject.global_position)
		
		if canRespawn:
			for i in range(2, 0, -1):
				await get_tree().create_timer(1).timeout
			deadObject.visible = false
			
			print("Respawning...")
			for i in range(waitTime * 2 - 2, 0, -1):
				await get_tree().create_timer(1).timeout
				print(i)
			deadObject.global_position = spawnPoint
			deadObject.visible = true
			
			if isPlayer == true:
				playerAnimation = "default"
			
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


func effect(Sound, shakeObject, shakeAmount, chosenParticle, particleAmount):
	play(Sound)
	shake(shakeObject, shakeAmount)
	#particle()


func shake(shakeObject, shakeAmount):
	shakeObject.rotation = shakeAmount * randf_range(-1, 1)
	shakeObject.offset.x = 0.8 * shakeAmount * randf_range(-1, 1)
	shakeObject.offset.y = 0.4 * shakeAmount * randf_range(-1, 1)


func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		available.append(player)
		player.finished.connect(_on_stream_finished.bind(player))
		player.bus = bus


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)


func play(sound_path):
	queue.append(sound_path)


func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
