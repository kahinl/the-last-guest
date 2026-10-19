extends Node3D

@onready var kid = $AnimationPlayer
@onready var bro = $Bro/AnimationPlayer
@onready var talk = $BroTalking
@onready var tea = $Tea
@onready var speech = $Talk/AnimationPlayer
@onready var light = $white/AnimationPlayer
@onready var black = $Black/AnimationPlayer

func _ready() -> void:
	Wind.stop()
	Comfy.stop()
	
	light.play("light_out")
	var player = get_tree().current_scene.find_child("Player", true, false)

	if player:
		player.freeze()  
		player.rotation = player.rotation
		if player.has_node("Head"):
			player.get_node("Head").rotation = player.get_node("Head").rotation

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	kid.play("kid")
	
	bro.play("mixamo_com")
	
	await get_tree().create_timer(3).timeout

	talk.play()
	
	run_tea_sequence()

	speech.play("T1")
	await speech.animation_finished
	speech.play("T2")
	await speech.animation_finished
	speech.play("T3")

func run_tea_sequence():
	await get_tree().create_timer(18.80).timeout
	bro.stop()
	bro.play("mixamo_com")
	bro.seek(22, true)
	
	await get_tree().create_timer(7).timeout
	tea.play()
	await get_tree().create_timer(9).timeout
	
	GameState.Reset2 = true
	black.play("black_in")
	await black.animation_finished
	
	tea.stop()
	$boiling.stop()
	$dishes.stop()
	$birds.stop()
	
	get_tree().change_scene_to_file("res://assets/House/Floor1/Basement.tscn")

	
	
