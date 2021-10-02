extends Node

func _ready():
	pass # Replace with function body.

func parse_file(file_path: String):
	
	var file = File.new()
	assert(file.file_exists(file_path))
	
	file.open(file_path, File.READ)
	var json_object = JSON.parse(file.get_as_text()).result
	
	file.close()
	return json_object
