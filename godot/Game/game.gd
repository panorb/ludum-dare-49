extends Control

onready var control_panel = get_node("ControlPanel")
onready var repeat_choice = get_node("RepeatChoice")

var last_ended_chapter := ""

func _ready():
	control_panel.load_character("russian-officer")
	control_panel.play_chapter("beginning")
	
	control_panel.connect("chapter_ended", self, "_on_chapter_ended")

func _on_chapter_ended(chapter_id):
	last_ended_chapter = chapter_id
	
	if chapter_id in ["beginning", "instructions"]:
		repeat_choice.present()
	
	if chapter_id == "repeat":
		control_panel.play_chapter("instructions")


func _on_RepeatChoice_proceed_selected():
	if last_ended_chapter in ["beginning", "instructions"]:
		control_panel.play_chapter("example")


func _on_RepeatChoice_repeat_selected():
	if last_ended_chapter in ["beginning", "instructions"]:
		control_panel.play_chapter("repeat")
