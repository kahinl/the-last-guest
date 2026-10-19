extends StaticBody3D

@onready var prompt_play = $"../play1/hover"
@onready var pos = $AnimationPlayer
@onready var cry1 = $"../cry"
@onready var cry2 = $"../cry2"
@onready var pick = $"../pickup"
@onready var hung = $"../hungup"
@onready var ringing = $"../Ring"
@onready var run = $"../running"
@onready var line = $"../extraSpeech/line"

var is_ringing = false

func _ready():
	GameState.phone_scene_visits += 1

	if not GameState.phone_picked:
		if GameState.phone_scene_visits >= 3:
			start_ringing()
		return

	# Ilk arama bittikten sonra telefon iki gec olay icin tekrar calar (G10)
	if _late_call_pending():
		$CollisionShape3D.disabled = false
		start_ringing()

func _late_call_pending():
	if GameState.phone_scene_visits >= 5 and not GameState.phone2_done:
		return true
	return GameState.final_truth_interacted and not GameState.phone_last_done

func start_ringing():
	is_ringing = true
	ringing.play()

func interact():
	if not is_ringing:
		return

	is_ringing = false
	if ringing.playing:
		ringing.stop()

	if GameState.phone_picked:
		await _late_call()
		return

	GameState.phone_picked = true
	pick.play()
	pos.play("phone")
	await pos.animation_finished
	pos.pause()
	
	$CollisionShape3D.disabled = true
	
	await get_tree().create_timer(1).timeout 
	cry1.play()
	await cry1.finished
	cry2.play()
	run.play(3)
	await cry2.finished
	
	
	pos.play("RESET")
	await pos.animation_finished
	pos.pause()
	hung.play()

func _late_call():
	pick.play()
	pos.play("phone")
	await pos.animation_finished
	pos.pause()
	$CollisionShape3D.disabled = true

	await get_tree().create_timer(1).timeout

	if not GameState.phone2_done:
		GameState.phone2_done = true
		cry1.play()
		await cry1.finished
		await Speech.say(line, "phone2_1")
	else:
		GameState.phone_last_done = true
		await Speech.say(line, "phone_last")

	pos.play("RESET")
	await pos.animation_finished
	pos.pause()
	hung.play()
	
	
	

func show_prompt():
	if is_ringing:
		prompt_play.visible = true

func hide_prompt():
	if prompt_play:
		prompt_play.visible = false
