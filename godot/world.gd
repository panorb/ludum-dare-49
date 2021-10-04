extends Node

onready var main_menu = preload("res://MainMenu/MainMenu.tscn")
onready var game = preload("res://Game/Game.tscn")

var scenes = {}

var current_scene_node = null

func _ready():
	scenes = {
		"MainMenu": main_menu,
		"Game": game
	}
	default_view()

func exit_game():
	get_tree().quit()

func start_game():
	change_scene(scenes["Game"])
	
func change_scene(new_scene_name):
	if not new_scene_name in scenes:
		return
	if current_scene_node:	
		current_scene_node.queue_free()
	var scene_instance = scenes[new_scene_name].instance()
	current_scene_node = scene_instance
	current_scene_node.connect("change_scene", self, "change_scene")
	self.add_child(scene_instance)

func default_view():
	change_scene("MainMenu")


