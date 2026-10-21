extends Node
## Hub'daki misafir defterinin uc okumasini dogrular:
##   1. ilk okuma            -> hub_note   (olum varsa hub_note_dead)
##   2. ikinci okuma         -> hub_note_2 (ikinci isim: agabey)
##   3. olum sonrasi ilk kez -> hub_note_dead
## Speech.say Label'in text'ine ANAHTARI yazar, o yuzden anahtar dogrudan okunuyor.
##   godot --headless --path . tools/test_hubnote.tscn


func _ready() -> void:
	await get_tree().process_frame        # root'un cocuk kurmasi bitsin
	var fails := 0
	fails += await _run(0)
	fails += await _run(3)
	print("SONUC: %s" % ("DEFTER OKUMALARI DOGRU" if fails == 0 else "%d OKUMA YANLIS" % fails))
	get_tree().quit(1 if fails > 0 else 0)


func _run(deaths: int) -> int:
	for k in ["hub_note_seen", "hub_note_2_seen"]:
		GameState.set_flag(k, false)
	GameState.deaths = deaths
	var hub: Node = (load("res://assets/Backrooms/hub.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(hub)
	await get_tree().physics_frame
	await get_tree().physics_frame

	# Sahnenin kendi altyazi etiketi var (gen_levels extraSpeech uretiyor);
	# yeni bir tane eklemek ayni ad carismasi yuzunden sessizce yeniden
	# adlandiriliyor ve test yanlis etiketi okuyordu.
	var lbl := hub.get_node("extraSpeech/line") as Label
	lbl.text = ""

	var note := hub.get_node("hubnote")
	var want1 := "hub_note_dead" if deaths > 0 else "hub_note"
	var got1 := await _read(note, lbl)
	var got2 := await _read(note, lbl)

	var bad := 0
	if got1 != want1:
		bad += 1
		print("BUG deaths=%d ilk okuma %s olmaliydi, %s geldi" % [deaths, want1, got1])
	else:
		print("OK  deaths=%d ilk okuma = %s" % [deaths, got1])
	if got2 != "hub_note_2":
		bad += 1
		print("BUG ikinci okuma hub_note_2 olmaliydi, %s geldi" % got2)
	else:
		print("OK  deaths=%d ikinci okuma = hub_note_2" % deaths)

	hub.free()
	await get_tree().process_frame
	return bad


func _read(note: Node, lbl: Label) -> String:
	lbl.text = ""
	# interact() konusma bitene kadar _used ile kilitli; testte 8 sn beklemek
	# yerine kilidi elle aciyoruz (Speech.say text'i hemen yaziyor).
	note._used = false
	note.interact()
	# Speech.say bir tween; kisa karelerle bekle, anahtar yazilmis olur
	for i in 5:
		await get_tree().process_frame
	return String(lbl.text)
