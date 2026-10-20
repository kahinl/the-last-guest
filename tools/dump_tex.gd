extends SceneTree
## .res dokularini PNG olarak disari aktarir (gorsel tani icin).
func _init() -> void:
	var dir := "res://assets/backrooms/textures/"
	var out := "/root/texdump/"
	DirAccess.make_dir_recursive_absolute(out)
	var d := DirAccess.open(dir)
	if d == null:
		print("NO DIR")
		quit(1); return
	for f in d.get_files():
		if not f.ends_with(".res"):
			continue
		var r := load(dir + f)
		var img: Image = null
		if r is Image:
			img = r
		elif r is Texture2D:
			img = (r as Texture2D).get_image()
		if img == null:
			print("SKIP %s (%s)" % [f, typeof(r)])
			continue
		var cp := img
		if img.get_format() != Image.FORMAT_RGBA8:
			cp = img.duplicate()
			cp.convert(Image.FORMAT_RGBA8)
		cp.save_png(out + f.get_basename() + ".png")
		print("DUMP %s %dx%d" % [f, img.get_width(), img.get_height()])
	quit()
