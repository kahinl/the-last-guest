extends Node3D
## Backrooms genellestirilmis atmosfer: titreyen isik + zamanlanmis fisilti,
## uzaktan varlik hirlamasi ve metal/boru sarsintilari. Sahnedeki "amb" dugumune
## asilir; bos birakilan NodePath'lar atlanir.

@export var flicker_light: NodePath
@export var whisper_player: NodePath
@export var growl_player: NodePath
@export var sfx_player: NodePath
@export var surface: String = ""
@export var drain_sanity: bool = false
@export var sanity_rate: float = 0.6

var _rng := RandomNumberGenerator.new()
var _sanity_frac: float = 0.0
var _light: OmniLight3D = null
var _flicker_acc: float = 0.0

##  Titrek 20 Hz'de yeter; 60 Hz'de her karede OmniLight uniform guncellemesi
##  level0'daki 11 isik icin bosuna GPU'ya yazilmak demek.
const FLICKER_STEP := 0.05


func _ready() -> void:
	_rng.randomize()
	if surface != "":
		GameState.step_surface = surface
	# Hub'a ulasan oyuncu Level 0'i "görmüş" sayılır: otel artik baska bir yer
	var sc := get_parent()
	if sc and String(sc.scene_file_path).contains("hub"):
		GameState.backrooms_survived = true
	# Backrooms'a giren oyuncu idare eder: fener artik her zaman cepte
	GameState.flashpicked = true
	if not GameState.flashlight_on:
		GameState.flashlight_on = true
		var p := get_parent().get_node_or_null("Player") as Node3D
		if p:
			var f := p.get_node_or_null("Head/Camera3D/flash")
			if f:
				f.visible = true
	_schedule(whisper_player, 22.0, 55.0)
	_schedule(growl_player, 40.0, 90.0)
	_schedule(sfx_player, 15.0, 40.0)
	if not flicker_light.is_empty():
		_light = get_node_or_null(flicker_light) as OmniLight3D
		if _light == null:
			push_warning("backrooms_amb: flicker_light cozulemedi: %s" % flicker_light)


func _process(delta: float) -> void:
	if drain_sanity:
		GameState.sanity = maxi(0, GameState.sanity - int(sanity_rate * delta * 10))
		var rem: float = (sanity_rate * delta * 10) - int(sanity_rate * delta * 10)
		_sanity_frac += rem
		if _sanity_frac >= 1.0:
			GameState.sanity = maxi(0, GameState.sanity - 1)
			_sanity_frac -= 1.0
	if flicker_light.is_empty() or _light == null:
		return
	_flicker_acc += delta
	if _flicker_acc < FLICKER_STEP:
		return
	_flicker_acc = 0.0
	var t := Time.get_ticks_msec() / 1000.0
	var f := 0.8 + 0.12 * sin(t * 11.0) + 0.06 * sin(t * 37.0)
	if _rng.randf() < 0.018:
		f *= 0.12
	_light.light_energy = maxf(0.05, f)


func _schedule(path: NodePath, lo: float, hi: float) -> void:
	if path.is_empty():
		return
	while true:
		await get_tree().create_timer(_rng.randf_range(lo, hi)).timeout
		if not is_inside_tree():
			return
		var p := get_node_or_null(path) as AudioStreamPlayer3D
		if p and not p.playing:
			p.play()
