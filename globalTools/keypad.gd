extends StaticBody3D
## YENIDEN KURULDU - orijinal globalTools/KeyPad.tscn repoda yok.
## Mutfaktaki bodrum kapisi (toBasement.gd) fullAccess + correct_code ister;
## ikisini de baska hicbir script set etmiyor, o yuzden dogru kod buradan acilir.
## Kod ipucu: newspaper_1 -> "March 14th" -> 0314  (G19)

@export var code: String = "0314"

@onready var prompt = $play1/hover
@onready var ui = $"../UI"
@onready var display = $"../UI/Panel/Display"
@onready var grid = $"../UI/Panel/Grid"
@onready var close_button = $"../UI/Panel/Close"
@onready var beep = $"../UI/Beep"

var _open := false


func _ready() -> void:
	if GameState.correct_code:
		get_parent().queue_free()
		return
	for b in grid.get_children():
		b.pressed.connect(_on_key.bind(String(b.text)))
	close_button.pressed.connect(_close)


func interact() -> void:
	if _open or GameState.correct_code:
		return
	_open_ui()


func _open_ui() -> void:
	_open = true
	display.text = ""
	ui.visible = true
	hide_prompt()
	GameState.interaction_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _close() -> void:
	_open = false
	ui.visible = false
	GameState.interaction_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_key(t: String) -> void:
	if beep:
		beep.play()
	if t == "C":
		display.text = ""
	elif t == "OK":
		_submit()
	elif display.text.length() < code.length():
		display.text += t


func _submit() -> void:
	if display.text != code:
		display.text = ""
		return
	GameState.correct_code = true
	GameState.fullAccess = true
	_close()
	get_parent().queue_free()


func show_prompt() -> void:
	if not _open and not GameState.correct_code:
		prompt.visible = true


func hide_prompt() -> void:
	if prompt:
		prompt.visible = false
