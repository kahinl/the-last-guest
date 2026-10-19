extends StaticBody3D


@onready var prompt_play = $"../play1/hover"
@onready var speech = $"speech/speech1/1"
@onready var whisper =$"../WhisperPlayer"
@onready var line = $"../extraSpeech/line"



func interact():
	if not GameState.room1_picture_seen:
		GameState.room1_picture_seen = true
		speech.play("s1")
		whisper.play()
		await speech.animation_finished
		speech.stop()
		await get_tree().create_timer(3).timeout
		whisper.stop()
		if speech.has_animation("s2"):
			speech.play("s2")
			await speech.animation_finished
			speech.stop()
		return

	if GameState.mom_letter_read:
		return

	GameState.mom_letter_read = true
	await Speech.say(line, "mom_letter1")
	await Speech.say(line, "mom_letter2")


func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
