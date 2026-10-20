extends Node3D

@onready var fade = $FadeLayer/AnimationPlayer
@onready var speech = $Speech/AnimationPlayer


func _ready() -> void:
	Wind.stop()
	GameState.flashlight_on = false
	GameState.flashpicked = false
	fade.play("fade_out")
	await fade.animation_finished

	await get_tree().create_timer(2).timeout
	speech.play("s1")
	await speech.animation_finished
	$"Speech/1".visible = false

	await get_tree().create_timer(2).timeout
	speech.play("s2")
	await speech.animation_finished
	$"Speech/2".visible = false

	await get_tree().create_timer(2).timeout
	speech.play("s3")
	await speech.animation_finished
	$"Speech/3".visible = false
