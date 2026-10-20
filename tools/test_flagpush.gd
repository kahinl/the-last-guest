extends Node
## requires_flag itmesini dogrular: bayrak GameState.set_flag ile yazildigi anda
## inspect_item gorunur olmali (eskiden _process'te her karede yoklanirdi).
##   godot --headless --path . tools/test_flagpush.tscn

const SCENES := [
	"res://assets/House/Floor2/hallWay/hallWay.tscn",
	"res://assets/House/Floor2/Bedrooms/room2.tscn",
	"res://assets/Backrooms/level2.tscn",
]


func _ready() -> void:
	# root.hazir: _ready icinden root'a cocuk eklemek "busy setting up children"
	# ile sessizce basarisiz olur (ilk sahne hic agaca girmez, yanlis pozitif).
	await get_tree().process_frame
	var checked := 0
	var failed := 0
	for path in SCENES:
		var inst: Node = (load(path) as PackedScene).instantiate()
		get_tree().root.add_child(inst)
		await get_tree().process_frame
		if not inst.is_inside_tree():
			print("BUG: sahne agaca giremedi: %s" % path)
			failed += 1
			continue
		for n in _all(inst):
			var req := String(n.get("requires_flag")) if n.has_method("_apply_visibility") else ""
			if req == "":
				continue
			checked += 1
			var before: bool = n.visible
			GameState.set_flag(req, true)
			await get_tree().process_frame
			var after: bool = n.visible
			var layer_ok: bool = int(n.collision_layer) == 1
			if after and layer_ok:
				print("FP OK   %-26s %s -> gorunur (onceki=%s)" % [n.name, req, before])
			else:
				failed += 1
				print("FP BUG  %-26s %s -> visible=%s layer=%s" % [n.name, req, after, layer_ok])
		inst.queue_free()
		await get_tree().process_frame
	if failed == 0:
		print("OK: %d nesnede bayrak itmesi calisiyor" % checked)
	else:
		print("BUG: %d/%d nesnede itme calismadi" % [failed, checked])
	get_tree().quit(1 if failed > 0 else 0)


func _all(n: Node) -> Array[Node]:
	var out: Array[Node] = [n]
	for c in n.get_children():
		out.append_array(_all(c))
	return out
