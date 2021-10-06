extends Panel

onready var leaked_info_label = get_node("VBoxContainer/LeakedInfo")
onready var tween = get_node("Tween")
onready var bling_player = get_node("BlingPlayer")

var text : String = "" setget _on_text_set

func fade_in():
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2.0, Tween.TRANS_EXPO)
	tween.start()

func fade_out():
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.0, Tween.TRANS_EXPO)
	tween.start()

func _on_text_set(val):
	text = val
	leaked_info_label.text = val
	
	if text:
		bling_player.play()
	tween.interpolate_property(leaked_info_label, "custom_colors/default_color", Color.aqua, Color.white, 0.4, Tween.TRANS_EXPO)
	tween.start()

