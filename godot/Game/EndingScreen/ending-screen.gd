extends ColorRect

onready var tween = get_node("Tween")
onready var label = get_node("Label")

func fade_in(ending_text):
	label.text = ending_text
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2.0, Tween.TRANS_EXPO)
	tween.start()
