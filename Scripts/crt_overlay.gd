extends ColorRect
## Tam ekran CRT / scanline overlay'i.
##
## player.gdshader `hint_screen_texture` kullaniyor: her karede tam framebuffer
## kopyasi + piksel basina uc ekran ornegi demek. Bu, projedeki tek seferde en
## buyuk GPU maliyeti (19 seviye + ana menu). Aperture-grille bilincli bir sanat
## karari oldugu icin kaldirilmadi; ayarlardan kapatilabilir hale getirildi.
## visible=false -> Control hic cizilmez, ekran dokusu da orneklenmez.


func _ready() -> void:
	visible = bool(GameState.crt_enabled)
	GameState.flag_set.connect(_on_game_state_flag_set)


func _on_game_state_flag_set(name: String, value: Variant) -> void:
	if name == "crt_enabled":
		visible = bool(value)
