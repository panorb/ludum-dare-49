extends Control

onready var tween = get_node("Tween")

signal proceed_selected
signal repeat_selected

func present():
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.8, Tween.TRANS_EXPO)
	self.visible = true
	tween.start()

func _hide():
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.3, Tween.TRANS_EXPO)
	tween.start()


func _on_Tween_tween_completed(_object, _key):
	self.visible = self.modulate.a != 0

func _on_ButtonProceed_pressed():
	emit_signal("proceed_selected")
	_hide()

func _on_ButtonRepeat_pressed():
	emit_signal("repeat_selected")
	_hide()
