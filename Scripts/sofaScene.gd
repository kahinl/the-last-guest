extends StaticBody3D

@onready var prompt_play = $"../../../../../../play1/hover"
@onready var Visualnoise = $"../../../../../../tvNoise"
@onready var action = $"../../../../../../AnimationPlayer"
@onready var fade = $"../../../../../../FadeLayer/AnimationPlayer"
@onready var T1 = $"../../../../../../finalTruthSounds/T1"
@onready var T2 = $"../../../../../../finalTruthSounds/T2"
@onready var T3 = $"../../../../../../finalTruthSounds/T3"
@onready var T4 = $"../../../../../../finalTruthSounds/T4"
@onready var Radio = $"../../../../../../RadionStatic"
@onready var Heart = $"../../../../../../HeartBearts"

# متغير لمنع تكرار الضغط أثناء تنفيذ المشهد
var is_transitioning = false

func _ready() -> void:
	if GameState.final_truth_interacted:
		if has_node("CollisionShape3D"):
			$CollisionShape3D.queue_free()

func interact():
	# إذا كان المشهد شغال حالياً، لا تفعل شيئاً
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# حفظ مرجع الشجرة (SceneTree) في متغير لتجنب خطأ الـ null لاحقاً
	var tree = get_tree()
	if not tree:
		return

	var player = tree.current_scene.find_child("Player", true, false)

	GameState.final_truth_interacted = true
	
	if has_node("CollisionShape3D"):
		$CollisionShape3D.queue_free()

	fade.play("fade_in")
	await fade.animation_finished
	fade.stop()

	if player:
		player.freeze()
		player.rotation.y = deg_to_rad(-90) 
		if player.has_node("Head"):
			player.get_node("Head").rotation.x = 0
		
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	Visualnoise.visible = true
	Radio.play()

	action.play("Sitting")
	await action.animation_finished  
	
	if player:
		player.global_transform = player.global_transform

	action.play("T1")
	T1.play()
	await action.animation_finished
	action.stop()
	
	action.play("T2")
	T2.play()
	await action.animation_finished
	action.stop()
	
	action.play("T3")
	T3.play()
	Heart.play(15)
	await action.animation_finished
	action.stop()
	
	action.play("T4")
	T4.play()
	await action.animation_finished
	action.stop()
	
	Visualnoise.visible = false
	Radio.stop()
	 
	action.play("passingOut")
	
	var wait_time = action.current_animation_length - 1.6
	if wait_time > 0:
		# استخدام tree.create_timer بدلاً من get_tree() مباشرة
		await tree.create_timer(wait_time).timeout
	
	fade.play("fade_in")
	await fade.animation_finished
	
	# التأكد أن النود لا تزال داخل الشجرة قبل الانتقال
	if is_inside_tree():
		get_tree().change_scene_to_file("res://assets/Dream/dream.tscn")

func show_prompt():
	if not is_transitioning:
		prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
