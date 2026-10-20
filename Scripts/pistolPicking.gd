extends StaticBody3D

@onready var prompt_play = $play2/hover
@onready var pistolPick = $"../Player/Head/Hands/AnimationPlayer"
@onready var hands = $"../Player/Head/Hands"

func interact():
	if not GameState.can_pick_pistol:
		return
		
	hide_prompt()
	
	GameState.set_flag("pistol_picked", true)
	visible = false
	collision_layer = 0 
	hands.visible = true
	
	pistolPick.play("allanims", -1, 0.5)
	pistolPick.seek(5.44, true)
	await get_tree().create_timer(0.8).timeout
	
	
	$"../charge".play()
	
	
	await get_tree().create_timer(2.20).timeout
	pistolPick.pause()

	# Ucuncu semptom: ilac alininca eller ilk kez sakinlesiyor (G12)
	if not GameState.symptom3_done:
		GameState.symptom3_done = true
		Speech.say(get_node_or_null("../extraSpeech/line") as Label, "symptom_3")

	queue_free()

func show_prompt():
	if GameState.can_pick_pistol:
		prompt_play.visible = true

func hide_prompt():
	if prompt_play:
		prompt_play.visible = false
