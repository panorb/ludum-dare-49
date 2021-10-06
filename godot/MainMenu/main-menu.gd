extends GameScene

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

func _on_StartButton_pressed():
	emit_signal("change_scene", "Game")


func _on_CheckBox_toggled(button_pressed):
	Globals.skip_introduction = button_pressed
