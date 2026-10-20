extends StaticBody3D
## SON C - on kapi (G16). frontKey varsa ormana, yani dongunun basina doner.
## Kapi acilinca ending_leave_1/2 satirlarini main.gd oynatir.

@onready var prompt_play = $play1/hover
@onready var line = $"../extraSpeech/line"


func interact() -> void:
	if not Input.is_action_just_pressed("ui_accept"):
		return

	if not GameState.frontKey_picked:
		await Speech.say(line, "hallWay_need1")
		return

	if GameState.ending_leave_done:
		return

	await Speech.say(line, "door_leave_1")
	GameState.ending_leave_done = true
	GameState.last_ending = "leave"
	FadeLayer.fade_and_change_scene("res://assets/main/main.tscn", "default")


func show_prompt() -> void:
	prompt_play.visible = true


func hide_prompt() -> void:
	prompt_play.visible = false
