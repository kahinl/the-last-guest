extends Node
## Araclar arasi sahne goruntusu: godot --path . tools/shot.tscn -- <scene> <outbase>
##                              [bright] [cam=x:z[:y[:ry]]]
## Iki kare kaydeder: baslangic yonu + 90 derece donmus.
## "bright": ortam isigini yukseltir. Doku/palet degil YERLESIM teshisi icin
## (otel seviyeleri el feneri olmadan zifiri karanlik render oluyor).
## "cam=": Player'i istenen noktaya koyar; sahnedeki sabit Player konumu
## bazi duvarlari gormek icin uygun olmayabiliyor.

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("usage: -- scene.tscn outbase")
		get_tree().quit(1)
		return
	var target: String = args[0]
	var outbase: String = args[1]
	var bright := false
	var cam := ""
	for o in args.slice(2):
		if o == "bright":
			bright = true
		elif o.begins_with("cam="):
			cam = o.substr(4)
	await get_tree().process_frame
	var inst := (load(target) as PackedScene).instantiate()
	get_tree().root.add_child(inst)
	if bright:
		_boost_light(inst)
	var player := inst.get_node_or_null("Player") as Node3D
	if player == null:
		for c in inst.get_children():
			if c is Node3D and c.name != "DirectionalLight3D":
				player = c
				break
	if player and cam != "":
		var p := cam.split(":")
		if p.size() >= 2:
			player.global_position = Vector3(float(p[0]), float(p[2]) if p.size() > 2 else 0.68, float(p[1]))
			if p.size() > 3:
				player.rotation.y = deg_to_rad(float(p[3]))
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


func _boost_light(root: Node) -> void:
	var found := 0
	var queue: Array[Node] = [root]
	while not queue.is_empty():
		var n: Node = queue.pop_back()
		if n is WorldEnvironment and (n as WorldEnvironment).environment != null:
			_flood((n as WorldEnvironment).environment)
			found += 1
		for c in n.get_children():
			queue.append(c)
	if found == 0:
		var we := WorldEnvironment.new()
		we.environment = Environment.new()
		_flood(we.environment)
		root.add_child(we)


func _flood(e: Environment) -> void:
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(1, 1, 1)
	e.ambient_light_energy = 3.0
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.04, 0.04, 0.05)
	e.tonemap_exposure = 1.8
	e.glow_enabled = false
	e.fog_enabled = false
	e.volumetric_fog_enabled = false
