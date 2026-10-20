extends SceneTree
## Backrooms asset pipeline: assets/backrooms/src altindaki ham girdileri
## (png/ogg/obj) Godot import sistemini BAYPAS ederek .res kaynaklarina cevirir.
## Calistirma (repo kokunden):
##   godot --headless --path . --script res://tools/build_assets.gd
## Neden: masaustu Godot bu ortamda --import'ta 'double free' ile cokuyor;
## bu yuzden Image/AudioStreamOggVorbis/ArrayMesh dogrudan ResourceSaver ile gomulur.

const SRC := "res://assets/backrooms/src/"
const OBJD := "res://assets/backrooms/src/obj/"
const TEX := "res://assets/backrooms/textures/"
const AUD := "res://assets/backrooms/audio/"
const MESH := "res://assets/backrooms/meshes/"

# Surekli dongu calacak ortam sesleri (dosya adi icerigiyle eslesir)
const LOOP_KEYS := [
	"547799", "Ambient01", "Ambient_Danger", "smiler_idle_drone",
	"amb_underground_room", "537769", "generator-off",
]

var VS: Array[Vector3] = []
var VNS: Array[Vector3] = []
var VTS: Array[Vector2] = []


func _init() -> void:
	_textures()
	_procedural()
	_audio()
	_meshes()
	print("BUILD DONE")
	quit(0)


func _textures() -> void:
	var d := DirAccess.open(SRC)
	d.list_dir_begin()
	var f := d.get_next()
	while f != "":
		if not d.current_is_dir() and (f.ends_with(".png") or f.ends_with(".jpg")):
			var img: Image = Image.load_from_file(SRC + f)
			if img:
				_save_tex(img, TEX + f.get_basename() + ".res")
			else:
				print("TEX ", f, " LOADFAIL")
		f = d.get_next()


##  Malzemeler albedo_texture = Texture2D bekliyor. Ham Image kaydedilirse
##  Godot onu texture olarak kabul etmiyor ve yuzey DOKUSUZ (düz renkli)
##  render ediliyor — Backrooms'da aylarca fark edilmeyen buyuk goruntu hatasi
##  buydu. Ayrica GPU tarafinda mipmap oldugu icin uzaktaki duvarlar
##  titremek yerine yumusak kaliyor.
func _save_tex(img: Image, path: String) -> void:
	if img == null:
		print("TEX FAIL ", path)
		return
	var w: int = img.get_width()
	var h: int = img.get_height()
	if not img.has_mipmaps() and _is_pot(w) and _is_pot(h):
		img.generate_mipmaps()
	var err := ResourceSaver.save(ImageTexture.create_from_image(img), path)
	print("TEX ", path.get_file(), " ", w, "x", h, " ", "OK" if err == OK else "FAIL")


func _is_pot(v: int) -> bool:
	return v > 0 and (v & (v - 1)) == 0


func _procedural() -> void:
	# Klasik Backrooms tavan karosu (beyaz panel + derz cizgileri + hafif grenli)
	var s := 512
	var img := Image.create(s, s, false, Image.FORMAT_RGB8)
	img.fill(Color(0.82, 0.80, 0.74))
	for i in range(0, s, s / 4):
		for x in range(s):
			img.set_pixel(x, i, Color(0.45, 0.43, 0.38))
			img.set_pixel(i, x, Color(0.45, 0.43, 0.38))
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 7
	for y in range(s):
		for x in range(s):
			var c := img.get_pixel(x, y)
			var n := (rnd.randf() - 0.5) * 0.06
			img.set_pixel(x, y, Color(c.r + n, c.g + n, c.b + n))
	_save_tex(img, TEX + "CeilingTiles.res")
	# Floresan panel (diffuzor + metal cerceve)
	var w := 256
	var h := 128
	var p := Image.create(w, h, false, Image.FORMAT_RGB8)
	p.fill(Color(0.98, 0.97, 0.90))
	for x in range(w):
		p.set_pixel(x, 0, Color(0.3, 0.3, 0.3)); p.set_pixel(x, 1, Color(0.3, 0.3, 0.3))
		p.set_pixel(x, h - 1, Color(0.3, 0.3, 0.3)); p.set_pixel(x, h - 2, Color(0.3, 0.3, 0.3))
	for y in range(h):
		p.set_pixel(0, y, Color(0.3, 0.3, 0.3)); p.set_pixel(1, y, Color(0.3, 0.3, 0.3))
		p.set_pixel(w - 1, y, Color(0.3, 0.3, 0.3)); p.set_pixel(w - 2, y, Color(0.3, 0.3, 0.3))
	_save_tex(p, TEX + "LightPanel.res")
	print("TEX procedural CeilingTiles/LightPanel OK")


func _audio() -> void:
	var d := DirAccess.open(SRC)
	d.list_dir_begin()
	var f := d.get_next()
	while f != "":
		if not d.current_is_dir() and f.ends_with(".ogg"):
			var file := FileAccess.open(SRC + f, FileAccess.READ)
			var bytes := file.get_buffer(file.get_length())
			file = null
			var st := AudioStreamOggVorbis.load_from_buffer(bytes)
			if st:
				for k in LOOP_KEYS:
					if f.find(k) != -1:
						st.loop = true
						break
				var err := ResourceSaver.save(st, AUD + f.get_basename() + ".ogg.res")
				print("AUD ", f, " ", "OK" if err == OK else "FAIL")
			else:
				print("AUD ", f, " DECODEFAIL (vorbis olmali, opus degil!)")
		f = d.get_next()


func _meshes() -> void:
	var d := DirAccess.open(OBJD)
	if d == null:
		return
	d.list_dir_begin()
	var f := d.get_next()
	while f != "":
		if not d.current_is_dir() and f.ends_with(".obj"):
			var m := _build_mesh(OBJD + f)
			if m:
				var err := ResourceSaver.save(m, MESH + f.get_basename() + ".mesh.res")
				print("MESH ", f, " ", "OK" if err == OK else "FAIL")
		f = d.get_next()


func _build_mesh(path: String) -> Mesh:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	VS.clear(); VNS.clear(); VTS.clear()
	var faces: Array = []
	while not file.eof_reached():
		var line := file.get_line()
		if line.begins_with("v "):
			var a := _nums(line); VS.append(Vector3(a[0], a[1], a[2]))
		elif line.begins_with("vn "):
			var a := _nums(line); VNS.append(Vector3(a[0], a[1], a[2]))
		elif line.begins_with("vt "):
			var a := _nums(line); VTS.append(Vector2(a[0], a[1]))
		elif line.begins_with("f "):
			var corner: Array = []
			for tk in line.substr(2).strip_edges().split(" "):
				if tk == "": continue
				corner.append_array(_corner(tk))
			faces.append(corner)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for corner in faces:
		var n: int = int(corner.size() / 3)
		for i in range(1, n - 1):
			for j in [0, i, i + 1]:
				_emit(st, corner, j * 3)
	return st.commit()


func _corner(tok: String) -> Array[int]:
	var parts := tok.split("/")
	var out: Array[int] = [0, 0, 0]
	out[0] = _resolve(parts[0], VS.size())
	if parts.size() > 1 and parts[1] != "": out[1] = _resolve(parts[1], VTS.size())
	if parts.size() > 2 and parts[2] != "": out[2] = _resolve(parts[2], VNS.size())
	return out


func _resolve(s: String, count: int) -> int:
	var i := s.to_int()
	if i < 0: i = count + i
	return i


func _nums(line: String) -> Array[float]:
	var out: Array[float] = []
	for p in line.substr(2).strip_edges().split(" "):
		if p == "": continue
		out.append(float(p))
	return out


func _emit(st: SurfaceTool, corner: Array, o: int) -> void:
	var vi: int = corner[o]
	var ti: int = corner[o + 1]
	var ni: int = corner[o + 2]
	if ni >= 1 and ni <= VNS.size(): st.set_normal(VNS[ni - 1])
	else: st.set_normal(Vector3.UP)
	if ti >= 1 and ti <= VTS.size(): st.set_uv(VTS[ti - 1])
	if vi >= 1 and vi <= VS.size(): st.add_vertex(VS[vi - 1])
	else: st.add_vertex(Vector3.ZERO)
