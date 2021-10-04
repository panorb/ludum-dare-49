extends Control

signal button_down
signal button_up

onready var texture_button = get_node("TextureButton")
onready var disabled_symbol = get_node("DisabledSymbol")

var enabled = true setget enabled_set

func _on_TextureButton_button_down():
	emit_signal("button_down")

func enabled_set(val):
	enabled = val
	
	disabled_symbol.visible = not enabled 
	texture_button.disabled = not enabled

func _on_TextureButton_button_up():
	emit_signal("button_up")

func _process(_delta):
	if enabled and not texture_button.has_focus():
		texture_button.grab_focus()
