extends StaticBody3D

@onready var prompt_play = $play3/hover
@onready var anim_player = $"../needs/AnimationPlayer"
@onready var audio_locked = $"../locked"

func interact():
	if not Input.is_action_just_pressed("ui_accept"):
		return

	if GameState.fullAccess and GameState.correct_code:
		FadeLayer.fade_and_change_scene(
			"res://assets/House/Floor1/Basement.tscn", 
			"default1"
		)
		return 

	else:
		anim_player.play("need1")

	if audio_locked and not audio_locked.playing:
		audio_locked.play()

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
