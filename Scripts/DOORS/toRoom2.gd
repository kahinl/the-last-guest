extends StaticBody3D


@onready var prompt_play =$"../play1/hover"



func interact():
	if Input.is_action_just_pressed("ui_accept"):
		if GameState.hospitalKey_picked == true:
			FadeLayer.fade_and_change_scene(
			"res://assets/House/Floor2/Bedrooms/room2.tscn",
			"default2"
		)
		else:
			$"../needs/AnimationPlayer".play("need1")
			var doorLocked = get_node_or_null("../locked")
			if doorLocked and not doorLocked.playing:
				doorLocked.play()


func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
