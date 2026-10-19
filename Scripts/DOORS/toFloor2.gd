extends StaticBody3D


@onready var prompt_play = $play4/hover



func interact():
	if Input.is_action_just_pressed("ui_accept"):
		if GameState.floor2Key_picked == true:
			FadeLayer.fade_and_change_scene(
			"res://assets/House/Floor2/hallWay/hallWay.tscn",
			"default1"
		)
		else:
			$"../../speech/C1/speech2/2".play("need2")
			var doorLocked = $"../../locked"
			if doorLocked and not doorLocked.playing:
				doorLocked.play()
			


func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
