extends Node

onready var main_menu = preload("res://MainMenu/MainMenu.tscn")
onready var game = preload("res://Game/Game.tscn")

var current_scene_node = null

func _ready():
	default_view()

func exit_game():
	get_tree().quit()

func start_game():
	change_scene(game)
	
func change_scene(new_scene):
	if current_scene_node:	
		current_scene_node.queue_free()
	var scene_instance = new_scene.instance()
	scene_instance.initialize(self)
	current_scene_node = scene_instance
	self.add_child(scene_instance)

func default_view():
	change_scene(main_menu)


