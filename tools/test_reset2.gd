extends Node
## Simulasyon: ruya sonrasi bodrum (Reset2) -> birakiliyor mu, box_seen otomatik mi,
## ikinci yuklemede (olum simülasyonu) tabanca masada mi?

func _ready() -> void:
	await get_tree().process_frame
	GameState.Reset2 = true
	GameState.can_pick_pistol = false
	GameState.box_seen = false
	_load()
	for i in 5:
		await get_tree().create_timer(2.0).timeout
	var p := _player()
	print("A: frozen=%s box_seen=%s Reset2=%s can_pick=%s pistol_y=%s" % [
		str(p.frozen) if p else "NOP", GameState.box_seen, GameState.Reset2,
		GameState.can_pick_pistol, _pistol_y()])
	# olum simülasyonu: sahneyi yeniden yukle
	GameState.pistol_picked = false
	_load()
	await get_tree().create_timer(2.0).timeout
	var p2 := _player()
	print("B: frozen=%s pistol_y=%s (0.07 olmali)" % [str(p2.frozen) if p2 else "NOP", _pistol_y()])
	if p2 and not p2.frozen and absf(_pistol_y() - 0.07) < 0.05:
		print("OK: olum sonrasi akici")
	else:
		print("BUG: olum sonrasi sorunlu")
	get_tree().quit()

var _cur: Node = null

func _load() -> void:
	if _cur:
		_cur.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	var b := (load("res://assets/House/Floor1/Basement.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(b)
	get_tree().current_scene = b
	_cur = b

func _player() -> Node:
	var cs := get_tree().current_scene
	return cs.find_child("Player", true, false) if cs else null

func _pistol_y() -> float:
	var cs := get_tree().current_scene
	var pi := cs.get_node_or_null("Pistol") if cs else null
	return pi.position.y if pi else -999.0
