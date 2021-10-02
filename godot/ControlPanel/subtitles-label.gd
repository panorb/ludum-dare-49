extends RichTextLabel

var subtitles_dict : Array = []
var animation_name : String = "Subtitles"
var current_animation : Animation = null
var method_track_index : int = 0

onready var animation_player = get_node("AnimationPlayer")

func _ready():
	animation_player.connect("text_started", self, "_on_text_started")
	animation_player.connect("text_ended", self, "_on_text_ended")

func map_subtitles_to_animation(subtitles_json):
	subtitles_dict = subtitles_json

	var duration = _subtitles_duration()
	current_animation = Animation.new()
	
	method_track_index = current_animation.add_track(Animation.TYPE_METHOD)
	current_animation.track_set_path(method_track_index, animation_player.get_path())

	current_animation.length = duration

	for text_interval in subtitles_dict:
		assert("start" in text_interval)
		assert("end" in text_interval)
		assert("text" in text_interval)
		
		_set_text_start_animation(text_interval)
		_set_text_end_animation(text_interval)

	animation_player.add_animation(animation_name, current_animation)
	animation_player.set_current_animation(animation_name)

func start_subtitles():
	animation_player.play()
	
func _subtitles_duration():
	if subtitles_dict.empty():
		return 0;

	var last_interval = subtitles_dict[subtitles_dict.size()-1]
	assert("end" in last_interval)
	return float(last_interval["end"])

func _set_text_start_animation(text_interval):
	if not current_animation:
		return

	current_animation.track_insert_key(method_track_index, float(text_interval["start"]), 
									{	"method" : "emit_signal" , 
										"args" : ["text_started", text_interval["index"]]
									})

func _set_text_end_animation(text_interval):
	if not current_animation:
		return
		
	current_animation.track_insert_key(method_track_index, float(text_interval["end"]), 
									{	"method" : "emit_signal" , 
										"args" : ["text_ended", text_interval["index"]]
									})

func _on_text_started(index : int):
	_render_text(index)

func _on_text_ended(index : int):
	pass

func _render_text(current_index : int = -1):
	var line = ""
	for index in range(current_index - 2, current_index + 2):
		if index < 0 or index >= subtitles_dict.size():
			continue
		
		var text_element = ""
		if index == current_index:
			text_element = "[b]" + subtitles_dict[index]["text"] + "[/b]"
		else:
			text_element = subtitles_dict[index]["text"]
		line = line + " " + text_element

	#self.bbcode_text = line
	self.bbcode_text = subtitles_dict[current_index-1]["text"]
