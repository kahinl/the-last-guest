extends Node
## Abi/canavar sahnesi simulasyonu: tabanci al -> canavar kalkar -> 2 ateste olur.

func _ready() -> void:
	await get_tree().process_frame
	GameState.Reset2 = false
	GameState.can_pick_pistol = true
	GameState.pistol_picked = false
	GameState.ending_letgo_done = true  # menuye donmesin, sadece die() akisini test et
	var b := (load("res://assets/House/Floor1/Basement.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(b)
	get_tree().current_scene = b
	await get_tree().create_timer(1.5).timeout
	var mon := b.get_node_or_null("Path3D/PathFollow3D/Monser")
	if mon == null:
		print("BUG: monster node missing")
		get_tree().quit(1); return
	print("M0: visible=%s activated=%s" % [mon.visible, mon.activated])
	# tabanci al
	GameState.pistol_picked = true
	await get_tree().create_timer(7.0).timeout  # Getting Up + Walk baslar
	print("M1: visible=%s activated=%s can_move=%s" % [mon.visible, mon.activated, mon.can_move])
	# iki ates (interact)
	mon.interact()
	await get_tree().create_timer(3.2).timeout
	print("M2: shooted=%s processing=%s" % [mon.shooted, mon.is_processing_shot])
	mon.interact()
	await get_tree().create_timer(1.0).timeout
	print("M3: die-called shooted=%s" % mon.shooted)
	print("OK: canavar akisi calisiyor" if mon.shooted >= 2 else "BUG: ates ise yaramadi")
	get_tree().quit()
