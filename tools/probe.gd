extends Node

## Spawn/spor noktası fizibilite sondası.
##   godot --path . tools/probe.tscn -- spawns <scene> [<scene> ...]
##     -> her sahnedeki TUM SpawnPoints markerlarini denetler
##   godot --path . tools/probe.tscn -- <scene> <x:z[:y0]> [...]
##     -> elle verilen aday noktaları denetler
## Bir nokta "DURULMAZ" ise: ya üstünde zemin yok, ya duruş kapsülü geometri
## içinde kalıyor, ya da zemin ile başlangıç arası 0.3-1.6 m bandının dışında.

var _level: Node3D

##  player.gd'deki SPAWN_FOOT_Y ile ayni kalmali.
const SPAWN_FOOT_Y = 0.68

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		print("usage: probe.tscn -- spawns <scene>... | -- <scene> <x:z[:y0]>...")
		get_tree().quit(2)
		return

	if args[0] == "spawns":
		for path in args.slice(1):
			var sc := await _enter(path)
			if sc == null:
				continue
			_report_player(sc, path.get_file())
			_check_spawns(sc, path.get_file())
			_leave(sc)
		get_tree().quit(0)
		return

	var sc := await _enter(args[0])
	if sc == null:
		get_tree().quit(1)
		return
	_report_player(sc, args[0].get_file())
	for p in args.slice(1):
		var parts := p.split(":")
		var y0 := 12.0
		if parts.size() > 2:
			y0 = float(parts[2])
		_probe_point(_space(), args[0].get_file(), float(parts[0]), float(parts[1]),
			y0, "nokta", true, y0 + 2.0)
	get_tree().quit(0)


func _enter(path: String) -> Node3D:
	var res := load(path)
	if res == null:
		print("PROBE !! yuklenemedi: %s" % path)
		return null
	var sc: Node3D = res.instantiate()
	add_child(sc)
	_level = sc
	await get_tree().physics_frame
	await get_tree().physics_frame
	return sc


func _leave(sc: Node) -> void:
	remove_child(sc)
	sc.free()
	_level = null


func _space() -> PhysicsDirectSpaceState3D:
	return _level.get_world_3d().direct_space_state


func _check_spawns(sc: Node3D, scene_file: String) -> void:
	var sp := sc.get_node_or_null("SpawnPoints")
	if sp == null:
		print("PROBE %-16s: SpawnPoints YOK" % scene_file)
		return
	for m in sp.get_children():
		if not (m is Node3D):
			continue
		var t: Transform3D = (m as Node3D).global_transform
		_probe_point(_space(), scene_file, t.origin.x, t.origin.z, t.origin.y,
			"spawn:" + m.name, true)


##  player.gd'deki _snap_to_floor ayni matematigi kullanir: markerin 0.9 m
## ustunden 2.0 m asagina isin, bulunan zemine +0.68 (ayak tabani).
func _probe_point(space: PhysicsDirectSpaceState3D, scene_file: String, x: float, z: float,
		marker_y: float, what: String, snap: bool = false, depth: float = 2.0) -> void:
	var down := space.intersect_ray(PhysicsRayQueryParameters3D.create(
		Vector3(x, marker_y + 0.9, z), Vector3(x, marker_y - depth, z),
		0xFFFFFFFF, _player_rids()))
	if down.is_empty():
		print("PROBE %-16s %-18s x=%.2f y=%.2f z=%.2f  %.1f m icinde ZEMIN YOK  << DURULMAZ" % [
			scene_file, what, x, marker_y, z, depth])
		return
	var floor_y: float = down.position.y
	var y := (floor_y + SPAWN_FOOT_Y) if snap else marker_y
	var body := CapsuleShape3D.new()
	body.height = 1.85
	body.radius = 0.5
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = body
	# 0.06 yukselt: govde tabani zemine tam degerse intersect_shape zemini de
	# engel sayiyor ve her saglam spawn yanlis pozitif veriyor.
	q.transform = Transform3D(Basis.IDENTITY, Vector3(x, y + 0.297 + 0.06, z))
	q.collision_mask = 0xFFFFFFFF
	q.collide_with_areas = false
	q.margin = 0.02
	q.exclude = _player_rids()
	var hits := space.intersect_shape(q, 8)
	var blockers: Array[String] = []
	for h in hits:
		blockers.append(String(h.collider.name))
	var sink: float = marker_y - floor_y - SPAWN_FOOT_Y
	print("PROBE %-16s %-18s x=%.2f z=%.2f  zemin=%.3f  marker_gomuk=%.2fm  snap_y=%.2f  blok=%s%s  %s" % [
		scene_file, what, x, z, floor_y, sink, y,
		"EVET" if not hits.is_empty() else "hayir",
		" (" + ", ".join(blockers) + ")" if not hits.is_empty() else "",
		"<< DURULMAZ" if not hits.is_empty() else "ok"])


func _report_player(sc: Node3D, scene_file: String) -> void:
	var pl := _find_player(sc)
	if pl == null:
		print("PROBE %-16s: sahnede Player node yok" % scene_file)
		return
	var t := pl.global_transform.origin
	var down := _space().intersect_ray(PhysicsRayQueryParameters3D.create(
		Vector3(t.x, t.y + 6, t.z), Vector3(t.x, t.y - 12, t.z), 0xFFFFFFFF, [pl.get_rid()]))
	if down.is_empty():
		print("PROBE %-16s: Player %.2f,%.2f,%.2f -> altinda ZEMIN YOK  << DURULMAZ" % [
			scene_file, t.x, t.y, t.z])
	else:
		print("PROBE %-16s: Player %.2f,%.2f,%.2f -> zemin=%.3f dusme=%.2fm (%s)" % [
			scene_file, t.x, t.y, t.z, down.position.y, t.y - down.position.y,
			String(down.collider.name)])


func _find_player(n: Node) -> CharacterBody3D:
	if n is CharacterBody3D and n.name == "Player":
		return n as CharacterBody3D
	for c in n.get_children():
		var r := _find_player(c)
		if r != null:
			return r
	return null


##  Işınlar Player'ın kendi gövdesine çarparsa kendi kapsülünü zemin sanır.
func _player_rids() -> Array[RID]:
	var out: Array[RID] = []
	if _level == null:
		return out
	var pl := _find_player(_level)
	if pl != null:
		out.append(pl.get_rid())
	return out
