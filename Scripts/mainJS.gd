extends Area3D

@export var look_speed: float = 0.6
@export var head_height_offset: float = 3.0 

func _on_body_entered(body):
	if body.name == "Player" and GameState.flashpicked:
		GameState.monster_encounters += 1
		if GameState.monster_encounters == 2:
			Speech.say(get_node_or_null("../../../extraSpeech/line") as Label, "monster_watch")
		if GameState.monster_encounters == 3:
			trigger_scare(body)

func trigger_scare(body):
	get_parent().visible = true
	
	var head = body.get_node("Head")
	var monster_pos = get_parent().global_position
	
	var body_target_pos = Vector3(monster_pos.x, body.global_position.y, monster_pos.z)
	var body_transform = body.global_transform.looking_at(body_target_pos, Vector3.UP)
	var body_quat = body_transform.basis.get_rotation_quaternion()
	
	var head_target_pos = Vector3(monster_pos.x, monster_pos.y + head_height_offset, monster_pos.z)
	var head_transform = head.global_transform.looking_at(head_target_pos, Vector3.UP)
	var head_quat = head_transform.basis.get_rotation_quaternion()
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(body, "global_basis", Basis(body_quat), look_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	tween.tween_property(head, "global_basis", Basis(head_quat), look_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.set_parallel(false) 
	tween.tween_property(head, "rotation:z", 0.0, 0.1)
	$"../../JS1".play()
	$"../../JS2".play()
	Comfy.play()

	await get_tree().create_timer(3).timeout
	$"../../JS2".stop()

	
	if has_node("../../Fade/AnimationPlayer"):
		$"../../Fade/AnimationPlayer".play("fade_out")
		get_parent().visible = false
		await $"../../Fade/AnimationPlayer".animation_finished

	
	
	
	$CollisionShape3D.set_deferred("disabled", true)
