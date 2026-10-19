extends StaticBody3D

@onready var prompt_play = $"../play3/hover"
@onready var speech = $"../speech/C1/speech1/1"

func _ready():
	if GameState.doorHandel_picked:
		if prompt_play: 
			prompt_play.visible = false
		queue_free()

func interact():
	GameState.doorHandel_picked = true
	
	hide_prompt()
	
	visible = false
	collision_layer = 0 
	
	speech.play("s2")
	await speech.animation_finished
	
	queue_free()

func show_prompt():
	if not GameState.doorHandel_picked:
		prompt_play.visible = true

func hide_prompt():
	if prompt_play:
		prompt_play.visible = false
