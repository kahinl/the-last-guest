extends CanvasLayer
## Minimal hayatta kalma HUD'u: yalnizca Backrooms seviyelerinde gorunur.
## Sanity cubugu + sanity dustukce koyulasan vinyet.

@onready var _bar: ProgressBar = $Bar
@onready var _vignette: ColorRect = $Vignette
@onready var _label: Label = $Label

var _cs: Node = null
var _in_br: bool = false
var _shown: int = -1


func _ready() -> void:
	visible = false
	_bar.modulate = Color(1, 1, 1, 0.85)


func _process(_delta: float) -> void:
	var cs := get_tree().current_scene
	if cs != _cs:
		_cs = cs
		_in_br = cs != null and cs.scene_file_path.contains("Backrooms")
		visible = _in_br
		_shown = -1
	if not _in_br:
		return

	# Akil 0-100 araliginda yavas akiyor; sayi degismediyse hicbir sey yazma.
	var s := clampi(int(GameState.sanity), 0, 100)
	if s == _shown:
		return
	_shown = s
	_bar.value = s
	_label.text = "AKIL %d" % s
	_vignette.color = Color(0.05, 0.0, 0.0, lerpf(0.0, 0.6, (100 - s) / 100.0))
