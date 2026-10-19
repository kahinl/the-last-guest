extends StaticBody3D


@onready var prompt_play = $play2/hover
@onready var speech = $"../AnimationPlayer"

func _ready():
	if GameState.frontKey_picked:
		queue_free()

func interact():
	if GameState.interaction_locked: return
	GameState.frontKey_picked = true
	visible = false
	collision_layer = 0
	speech.play("s2")
	await speech.animation_finished
	speech.stop()
	queue_free()
	
func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
