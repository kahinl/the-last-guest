extends Node

var _fb: Array[Font] = []

func _ready() -> void:
	var noto = FontFile.new()
	if noto.load_dynamic_font("res://assets/fonts/NotoSans-Regular.ttf") != OK:
		push_warning("FontFallback: NotoSans yuklenemedi")
	var arabic = FontFile.new()
	if arabic.load_dynamic_font("res://assets/fonts/NotoSansArabic-Regular.ttf") != OK:
		push_warning("FontFallback: NotoSansArabic yuklenemedi")
	_fb = [noto, arabic]
	get_tree().node_added.connect(_on_node_added)
	_patch_tree(get_tree().root)

func _on_node_added(node: Node) -> void:
	# Agac boyunca node_added her dugum icin ayrica calisiyor; alt agaci tekrar
	# taramak sahne yuklemesini O(N^2)'ye ceviriyordu (level0: 383 dugum).
	_patch_node(node)

func _patch_tree(node: Node) -> void:
	_patch_node(node)
	for child in node.get_children():
		_patch_tree(child)

func _patch_node(node: Node) -> void:
	var font: Font = null
	if node is Label or node is Button or node is RichTextLabel:
		font = node.get_theme_font("font")
	elif node is Label3D:
		font = node.font
	if font is FontFile and _fb.size() > 0 and font.fallbacks.is_empty():
		font.fallbacks = _fb
