extends RichTextLabel

signal text_started
signal text_ended(elapsed_time)

var subtitles_dict : Array = []
var animation_name : String = "Subtitles"
var current_animation : Animation = null
var method_track_index_start : int = 0
var method_track_index_end : int = 1

onready var animation_player = get_node("AnimationPlayer")

func _ready():
	animation_player.connect("text_started", self, "_on_text_started")
	animation_player.connect("text_ended", self, "_on_text_ended")

func map_subtitles_to_animation(subtitles_json):
	subtitles_dict = subtitles_json

	var duration = _subtitles_duration()
	current_animation = Animation.new()
	
	method_track_index_start = current_animation.add_track(Animation.TYPE_METHOD)
	method_track_index_end = current_animation.add_track(Animation.TYPE_METHOD)
	current_animation.track_set_path(method_track_index_start, animation_player.get_path())
	current_animation.track_set_path(method_track_index_end, animation_player.get_path())

	current_animation.length = duration

	for index in subtitles_dict.size():
		assert("start" in subtitles_dict[index])
		assert("end" in subtitles_dict[index])
		assert("text" in subtitles_dict[index])
		
		_set_text_start_animation(index)
		_set_text_end_animation(index)

	animation_player.add_animation(animation_name, current_animation)

func start_subtitles():
	animation_player.set_current_animation(animation_name)
	animation_player.play()
	
func _subtitles_duration():
	if subtitles_dict.empty():
		return 0;

	var last_interval = subtitles_dict[subtitles_dict.size()-1]
	assert("end" in last_interval)
	return float(last_interval["end"])

func _set_text_start_animation(index):
	if not current_animation:
		return

	current_animation.track_insert_key(method_track_index_start, subtitles_dict[index]["start"], 
									{	"method" : "emit_signal" , 
										"args" : ["text_started", index]
									})

func _set_text_end_animation(index):
	if not current_animation:
		return
		
	current_animation.track_insert_key(method_track_index_end, subtitles_dict[index]["end"], 
									{	"method" : "emit_signal" , 
										"args" : ["text_ended", index]
									})

func _on_text_started(index : int):
	_render_text(index)
	emit_signal("text_started", index)

func _on_text_ended(index : int):
	emit_signal("text_ended", index)

func _render_text(current_index):
	self.bbcode_text = ""
	
	var current_segment_id = subtitles_dict[current_index]["segment"]
	
	var line = ""
	var index = current_index - 1
	
	# 1. line
	# Part before the current text
	while index >= 0 and subtitles_dict[index]["segment"] == current_segment_id:
		line = subtitles_dict[index]["text"] + " " + line
		index -= 1
	
	# Current text
	line += "[color=#BF003F]" + subtitles_dict[current_index]["text"] + "[/color]"
	
	# Part after the current text
	index = current_index + 1
	while index < subtitles_dict.size() and subtitles_dict[index]["segment"] == current_segment_id:
		line += " " + subtitles_dict[index]["text"]
		index += 1
	
	self.bbcode_text = line
		
	# Reached end of text?
	if index >= subtitles_dict.size():
		return
	
	# 2. line
	line = ""
	while index < subtitles_dict.size() and subtitles_dict[index]["segment"] == current_segment_id + 1:
		line += subtitles_dict[index]["text"] + " "
		index += 1
	
	self.bbcode_text += "\n" +  line
	
	# Reached end of text?
	if index >= subtitles_dict.size():
		return
	
	# 3. line 
	line = ""
	while index < subtitles_dict.size() and subtitles_dict[index]["segment"] == current_segment_id + 2:
		line += subtitles_dict[index]["text"] + " "
		index += 1
	
	self.bbcode_text += "\n" + line
