extends SceneTree
## lang.csv -> lang.{en,ar,tr}.translation uretir (import baypas).
## Calistirma:
##   godot --headless --path . --script res://tools/build_translations.gd
## Neden: duzenli --import bu ortamda cokuyor; ayrica .import pipeline'i
## lang.csv'yi tek seferde en/ar uretiyordu, biz uc dil de (tr dahil) yaziyoruz.
## lang.csv sutunlari: keys,en,ar,tr  (virgullu alanlar tırnak icinde olmali!)

const CSV := "res://lang.csv"


func _init() -> void:
	var f := FileAccess.open(CSV, FileAccess.READ)
	if f == null:
		print("CSV ACILAMADI"); quit(1); return
	var langs := {"en": {}, "ar": {}, "tr": {}}
	var header := false
	var bad := 0
	while not f.eof_reached():
		var line := f.get_line()
		if line == "":
			continue
		if not header:
			header = true
			continue
		var cells := _parse(line)
		if cells.size() < 4:
			bad += 1
			print("KOTU SATIR (4 sutun degil): ", cells[0] if cells.size() else line)
			continue
		var key: String = cells[0]
		langs["en"][key] = cells[1]
		langs["ar"][key] = cells[2]
		langs["tr"][key] = cells[3]
	for loc in langs.keys():
		var t := Translation.new()
		t.locale = loc
		for k in langs[loc].keys():
			t.add_message(k, langs[loc][k])
		var err := ResourceSaver.save(t, "res://lang.%s.translation" % loc)
		print(loc, " -> ", "OK" if err == OK else "FAIL", " (", t.get_message_count(), " anahtar)")
	if bad > 0:
		print("UYARI: ", bad, " bozuk satir atlandi (tirnak eksigi olabilir)")
	quit(0)


func _parse(line: String) -> Array:
	var cells := []
	var cur := ""
	var inq := false
	var i := 0
	while i < line.length():
		var c := line[i]
		if inq:
			if c == '"':
				if i + 1 < line.length() and line[i + 1] == '"':
					cur += '"'; i += 1
				else:
					inq = false
			else:
				cur += c
		else:
			if c == '"':
				inq = true
			elif c == ',':
				cells.append(cur); cur = ""
			else:
				cur += c
		i += 1
	cells.append(cur)
	return cells
