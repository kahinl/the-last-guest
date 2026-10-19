extends CanvasLayer
## Minimal hayatta kalma HUD'u: yalnizca Backrooms seviyelerinde gorunur.
## Sanity cubugu + sanity dustukce koyulasan vinyet.

@onready var _bar: ProgressBar = $Bar
@onready var _vignette: ColorRect = $Vignette
@onready var _label: Label = $Label


func _process(_delta: float) -> void:
	var cs := get_tree().current_scene
	var in_br: bool = cs != null and cs.scene_file_path.contains("Backrooms")
	visible = in_br
	if not in_br:
		return
	var s := clampi(int(GameState.sanity), 0, 100)
	_bar.value = s
	_bar.modulate = Color(1, 1, 1, 0.85)
	_label.text = "AKIL %d" % s
	_vignette.color = Color(0.05, 0.0, 0.0, lerpf(0.0, 0.6, (100 - s) / 100.0))
