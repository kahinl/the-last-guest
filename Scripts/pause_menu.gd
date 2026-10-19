extends CanvasLayer

@onready var continue_btn = $VBoxContainer/ContinueButton
@onready var menu_btn = $VBoxContainer/MainMenuButton
@onready var quit_btn = $VBoxContainer/QuitButton
@onready var background = $Background
@onready var buttonPressed_sound = $ButtonPressed 

func _ready():
	hide()
	background.hide()
	
	continue_btn.pressed.connect(_on_continue_button_pressed)
	menu_btn.pressed.connect(_on_main_menu_button_pressed)
	quit_btn.pressed.connect(_on_quit_button_pressed)
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# التحقق مما إذا كان المشهد الحالي هو القائمة الرئيسية
		var current_scene_path = get_tree().current_scene.scene_file_path
		if current_scene_path == "res://assets/main/main_menu.tscn":
			return # اخرج من الوظيفة ولا تفعل شيئاً
		
		toggle_pause()
		buttonPressed_sound.play() 

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	
	visible = new_pause_state
	background.visible = new_pause_state
	
	if new_pause_state:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_continue_button_pressed():
	buttonPressed_sound.play() 
	toggle_pause()

func _on_main_menu_button_pressed():
	buttonPressed_sound.play() 
	get_tree().paused = false
	hide()
	background.hide()
	get_tree().change_scene_to_file("res://assets/main/main_menu.tscn")

func _on_quit_button_pressed():
	buttonPressed_sound.play() 
	get_tree().quit()
