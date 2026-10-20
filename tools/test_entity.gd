extends Node
## Varligin SES-gudumlu davranisini dogrular (backrooms_entity.gd).
##   godot --headless --path . tools/test_entity.tscn
##
## Iki sahtelesirme var: (1) gercek Player kontrolcusu yerine `noise` ozelligi
## olan sade bir govde, (2) `_process(delta)` elle adimlanıyor — boylece test
## cihazin fps'ine bagli kalmiyor (headless'ta kare suresi degisken).

class FakePlayer:
	extends Node3D
	var noise: float = 0.0
	func freeze() -> void:
		pass


const DT := 0.05


func _ready() -> void:
	await get_tree().process_frame
	var ent := _make_entity()
	var p := FakePlayer.new()
	p.name = "Player"
	get_tree().root.add_child(p)
	await get_tree().process_frame
	p.global_position = Vector3(0, 0, 12)
	ent._player = p
	ent._on_zone_entered(p)
	ent.set_process(false)   # adimlari elle suruyoruz

	var fails := 0

	# A1 — sessiz oyuncu: varlik hic uyanmamali (5 sn).
	p.noise = 0.0
	for i in int(5.0 / DT):
		ent._process(DT)
	fails += _check(ent._state == 0, "A1",
		"sessiz oyuncuda varlik uyanmadi (alert=%.2f)" % ent._alert,
		"sessiz oyuncuda varlik uyandi (state=%d)" % ent._state)

	# A2 — gurtulu oyuncu: uyanmali ve mesafe azalmali (ama yakalamamali:
	# 3 sn x 2.6 m/s = ~5 m, baslangic 12 m).
	var d0: float = p.global_position.distance_to(ent.global_position)
	p.noise = 1.0
	for i in int(3.0 / DT):
		ent._process(DT)
	var d1: float = p.global_position.distance_to(ent.global_position)
	fails += _check(ent._state == 1 and d1 < d0 - 0.5, "A2",
		"ses varligi uyandirdi ve %.2f m yaklastirdi (%.2f -> %.2f)" % [d0 - d1, d0, d1],
		"ses varligi uyandirmadi/yaklastirmadi (state=%d %.2f -> %.2f)" % [ent._state, d0, d1])

	# A3 — oyuncu susarsa varlik da oldugu yerde kalmali (1 sn).
	p.noise = 0.0
	var paused: float = p.global_position.distance_to(ent.global_position)
	for i in int(1.0 / DT):
		ent._process(DT)
	var still: float = p.global_position.distance_to(ent.global_position)
	fails += _check(absf(still - paused) < 0.05, "A3",
		"sessizlikte varlik hareket etmedi (%.2f m sabit)" % still,
		"oyuncu sessizken varlik hala yaklasiyor (%.2f -> %.2f)" % [paused, still])

	# A4 — yeterince sessizlik: geri cekilmeli ve govde gizlenmeli.
	for i in int(5.0 / DT):
		ent._process(DT)
	fails += _check(ent._state == 0 and not ent._body.visible, "A4",
		"varlik geri cekildi, govde gizli",
		"varlik geri cekilmedi (state=%d gorunur=%s)" % [ent._state, ent._body.visible])

	print("SONUC: %s" % ("TUM VARLIK TESTLERI GECTI" if fails == 0 else "%d TEST BASARISIZ" % fails))
	get_tree().quit(1 if fails > 0 else 0)


func _check(ok: bool, tag: String, good: String, bad: String) -> int:
	print(("OK  " if ok else "BUG ") + tag + " " + (good if ok else bad))
	return 0 if ok else 1


func _make_entity() -> Node3D:
	var ent: Node3D = (load("res://assets/Backrooms/entity.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(ent)
	ent.global_position = Vector3(0, 0, 0)
	return ent
