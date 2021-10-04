extends Control

onready var playback = get_node("Playback")
onready var repeat_choice = get_node("RepeatChoice")

var last_ended_chapter := ""
var remaining_energy := 100

func _ready():
	playback.load_character("russian-officer")
	playback.play_chapter("beginning")
	
	playback.connect("chapter_ended", self, "_on_chapter_ended")

func _on_chapter_ended(chapter_id):
	last_ended_chapter = chapter_id
	
	if chapter_id in ["beginning", "instructions"]:
		repeat_choice.present()
	
	if chapter_id == "repeat":
		playback.play_chapter("instructions")


func _on_RepeatChoice_proceed_selected():
	if last_ended_chapter in ["beginning", "instructions"]:
		playback.play_chapter("example")


func _on_RepeatChoice_repeat_selected():
	if last_ended_chapter in ["beginning", "instructions"]:
		playback.play_chapter("repeat")
