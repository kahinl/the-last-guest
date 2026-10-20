extends Node

var interaction_locked = false
var speech1_played = false
var flashpicked = false
var flashlight_on = false
var floor2Key_picked = false
var letter1_picked = false
var letter2_picked = false
var Cassette_picked = false
var casset_putted = false
var boxKey_picked = false
var hospitalKey_picked =false
var correct_code = false
var accessCard_picked = false # Otel temasinda: B1 bodrum kat anahtari (room2_4)
var fullAccess = false
var doorHandel_picked = false
var is_handel_installed = false
var frontKey_picked = false 
var room1js_entered = 0
var bathjs_entered = 0
var phone_scene_visits = 0
var phone_picked = false
var kitchen_entered = 0 
var Reset2 = false
var final_truth_interacted: bool = false
var pistol_picked = false
var can_pick_pistol = false
var monster_encounters: int = 0

# Kus sistemi
var bird_found = false
var bird2_found = false
var gift_bird_found = false
var birds_found: int = 0
var bird_all_seen = false

# Toplanabilirler ve belgeler
var recipe_read = false
var syringe_found = false
var mom_letter_read = false
var letter3_picked = false
var room3_speech_played = false
var attic_speech_played = false
var attic_2_seen = false
var attic_3_seen = false
var journal_01_read = false
var journal_02_read = false
var journal_03_read = false
var journal_04_read = false
var journal_05_read = false
var tape1_picked = false
var tape2_picked = false
var tape1_played = false
var tape2_played = false

# Tek seferlik incelemeler
var kitchen_mugs_seen = false
var newspaper_seen = false
var hallway_frame_seen = false
var lib_books_seen = false
var bath_mirror_seen = false
var monster_word_seen = false
var level0_photo_seen = false
var level0_speech_played = false
var level0_entered = 0
# Backrooms arc (Level 0 -> 1 -> 2 -> Hub)
var level0_key = false
var level0_water = false
var level0_nest_seen = false
var level1_speech_played = false
var level1_fuse1 = false
var level1_fuse2 = false
var level1_breaker_seen = false
var level2_speech_played = false
var level2_valve = false
var level2_saw_help = false
var hub_speech_played = false
var hub_note_seen = false
var backrooms_survived = false
var noclip_used = false
var wall_thin_seen = false
var sanity: int = 100
var deaths: int = 0
var step_surface: String = "wood"
var basement_props_seen = false
var box_seen = false
var base_chains_seen = false
var base_bed_seen = false
var room3_2_seen = false
var room3_3_seen = false
var room3_4_seen = false
var room3_5_seen = false
var lucid1_done = false
var room1_picture_seen = false

# Semptomlar ve telefon olaylari
var symptom1_done = false
var symptom2_done = false
var symptom3_done = false
var phone2_done = false
var phone_last_done = false

# Sonlar
var ending_letgo_done = false
var ending_holdon_done = false
var ending_leave_done = false
var is_frontkey_installed = false
