extends Node3D


# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	Wind.play()
	await get_tree().create_timer(2.0).timeout
	$breathing.play(3) 
	await get_tree().create_timer(10.0).timeout
	$breathing.stop()
	
	# SON C - on kapidan cikan oyuncu yine ormana, dongunun basina doner (G16)
	if GameState.ending_leave_done:
		await _ending_leave()
		return
	
	await  get_tree().create_timer(15).timeout
	$instractions/AnimationPlayer.play("inter")


func _ending_leave() -> void:
	await get_tree().create_timer(4.0).timeout
	var label := get_node_or_null("extraSpeech/line") as Label
	if label == null:
		push_warning("main: extraSpeech/line bulunamadi")
		return
	await Speech.say(label, "ending_leave_1")
	await Speech.say(label, "ending_leave_2")
	FadeLayer.fade_and_change_scene("res://assets/main/main_menu.tscn", "default")
