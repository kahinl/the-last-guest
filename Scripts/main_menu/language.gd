extends OptionButton

@onready var pressSound = $"../../../ButtonPressed" # Ensure this path is correct

var languages = {
	"English": "en",
	"العربية": "ar",
	"Türkçe": "tr"
}

func _ready():
	clear()
	for lang_name in languages.keys():
		add_item(lang_name)
	var current = TranslationServer.get_locale()
	for i in languages.size():
		if languages[languages.keys()[i]] == current:
			selected = i
			break
	
	item_selected.connect(_on_language_selected)

func _on_language_selected(index):
	if pressSound:
		pressSound.play()
		
	var selected_lang_name = get_item_text(index)
	var lang_code = languages[selected_lang_name]
	TranslationServer.set_locale(lang_code)
