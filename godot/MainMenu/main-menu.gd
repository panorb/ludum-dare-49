extends VBoxContainer

onready var animation_player = get_node("AnimationPlayer")

onready var quit_button = get_node("QuitButton")

# Called when the node enters the scene tree for the first time.
func _ready():
	quit_button.visible = OS.get_name() != "HTML5"
	animation_player.play("intro")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro":
		animation_player.play("idle")

func fade_out():
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
