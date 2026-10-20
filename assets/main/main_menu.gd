extends Node3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$CanvasLayer/AnimationPlayer.play("fade_out")
	Wind.stop()
	Comfy.stop()

	# CRT overlay ayari (B5): varsayilan acik, ana menude kapatilabilir.
	var crt := $Buttons/VBoxContainer/crt as CheckButton
	crt.button_pressed = bool(GameState.crt_enabled)
	crt.toggled.connect(_on_crt_toggled)


func _on_crt_toggled(on: bool) -> void:
	GameState.set_flag("crt_enabled", on)
