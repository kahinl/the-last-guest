extends StaticBody3D


@onready var prompt_play = $"../play1/hover"
@onready var speech = $"../AnimationPlayer"


func _ready():
	if GameState.phone_scene_visits >= 3 and not GameState.phone_picked:
		$"../Ring".play()
		
	if GameState.hospitalKey_picked:
		queue_free()

func interact():
	GameState.hospitalKey_picked = true
	hide()
	hide_prompt()
	process_mode = PROCESS_MODE_DISABLED 
	speech.play("s1")
	await speech.animation_finished

	queue_free()

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
