extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var loading = $AnimatedSprite2D
@onready var label = $Label

var next_spawn_name := "default"


func fade_and_change_scene(scene_path: String, spawn_name: String):
	next_spawn_name = spawn_name

	label.visible = true
	loading.visible = true
	loading.play("loading")

	anim.play("fade_in")
	$open.play()
	await anim.animation_finished

	ResourceLoader.load_threaded_request(scene_path)

	while ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	var packed_scene = ResourceLoader.load_threaded_get(scene_path)

	get_tree().change_scene_to_packed(packed_scene)

	anim.play_backwards("fade_in")
	await anim.animation_finished

	loading.stop()
	loading.visible = false
	label.visible = false
