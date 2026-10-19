extends Node
## Araclar arasi sahne goruntusu: godot --path . tools/shot.tscn -- <scene> <outbase>
## Iki kare kaydeder: baslangic yonu + 90 derece donmus.

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("usage: -- scene.tscn outbase")
		get_tree().quit(1)
		return
	var target: String = args[0]
	var outbase: String = args[1]
	await get_tree().process_frame
	var inst := (load(target) as PackedScene).instantiate()
	get_tree().root.add_child(inst)
	var player := inst.get_node_or_null("Player") as Node3D
	if player == null:
		for c in inst.get_children():
			if c is Node3D and c.name != "DirectionalLight3D":
				player = c
				break
	for i in 260:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(outbase + "_a.png")
	if player:
		player.rotate_y(2.5)
	for i in 60:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(outbase + "_b.png")
	if player:
		player.rotate_y(2.5)
	for i in 60:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(outbase + "_c.png")
	print("SHOT OK %s" % outbase)
	get_tree().quit()
