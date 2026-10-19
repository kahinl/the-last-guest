extends StaticBody3D

@onready var prompt_play = $"../play4/hover"
@onready var speech = $"../AnimationPlayer"

func _ready():
	if GameState.phone_scene_visits >= 3 and not GameState.phone_picked:
		$"../Ring".play()
	if GameState.accessCard_picked:
		if prompt_play: prompt_play.visible = false
		queue_free()

func interact():
	GameState.accessCard_picked = true

	
	hide_prompt()  
	visible = false
	collision_layer = 0 
	
	speech.play("s1")
	GameState.interaction_locked = false
	await speech.animation_finished
	queue_free()

func show_prompt():
	if not GameState.accessCard_picked:
		prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
