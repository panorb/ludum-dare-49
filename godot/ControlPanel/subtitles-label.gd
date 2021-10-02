extends RichTextLabel

var subtitles_dict : Array = []
var animation_name : String = "Subtitles"
var current_animation : Animation = null
var method_track_index : int = 0

onready var animation_player = get_node("AnimationPlayer")

func _ready():
	animation_player.connect("text_started", "_on_text_started")
	animation_player.connect("text_ended", "_on_text_ended")

func map_subtitles_to_animation(subtitles_json):
	subtitles_dict = subtitles_json

	var duration = _subtitles_duration()
	current_animation = Animation.new()
	animation_player.add_animation(animation_name, current_animation)
	animation_player.set_current_animation(animation_name)
	
	method_track_index = current_animation.add_track(Animation.TYPE_METHOD)

	animation_player.get_animation(animation_name).length = duration
	
	for interval in subtitles_dict:
		assert("begin" in interval)
		assert("end" in interval)
		assert("text" in interval)
		
		_set_text_start_animation(interval["begin"], interval["text"])
		_set_text_end_animation(interval["end"], interval["text"])

func start_subtitles():
	animation_player.play()
	
func _subtitles_duration():
	if subtitles_dict.empty():
		return 0;

	var last_interval = subtitles_dict[subtitles_dict.size()-1]
	assert("end" in last_interval)
	return last_interval["end"]

func _set_text_start_animation(time, text):
	animation_player.track_insert_key(method_track_index, time, 
									{	"method" : "emit_signal" , 
										"args" : ["text_started", text]
									})

func _set_text_end_animation(time, text):
	animation_player.track_insert_key(method_track_index, time, 
									{	"method" : "emit_signal" , 
										"args" : ["text_ended", text]
									})

func _on_text_started(text):
	self.text = text

func _on_text_ended(text):
	self.text = ""
