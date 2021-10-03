extends VBoxContainer

signal text_started
signal text_ended(elapsed_time)

var subtitles_dict : Array = []
var animation_name : String = "Subtitles"
var current_animation : Animation = null
var method_track_index_start : int = 0
var method_track_index_end : int = 1
var current_segment_id: int = -1
var current_index : int = -1
var next_lines: String = ""

onready var animation_player = get_node("AnimationPlayer")

onready var lines = [get_node("Line1"), get_node("Line2"), get_node("Line3")]

func _ready():
	animation_player.connect("text_started", self, "_on_text_started")
	animation_player.connect("text_ended", self, "_on_text_ended")

func _process(delta):
	_render_text()

func map_subtitles_to_animation(subtitles_json):
	subtitles_dict = subtitles_json["timing"]

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
	current_index = index
	if current_segment_id != subtitles_dict[index]["segment"]:
		current_segment_id = subtitles_dict[index]["segment"]
		_create_upcoming_lines()
	emit_signal("text_started", index)

func _on_text_ended(index : int):
	emit_signal("text_ended", index)

func _create_upcoming_lines():
	var index = current_index
	
	# Find the first index of the next segment
	while 	(index < subtitles_dict.size()) and \
			(subtitles_dict[index]["segment"] == current_segment_id):
		index += 1
	
	# Reached end of text?
	if index >= subtitles_dict.size():
		return
	
	for line_index in range(1,3):
		var line = ""
		while 	index < subtitles_dict.size() and \
				subtitles_dict[index]["segment"] == current_segment_id + line_index + 1:
				
				line = PoolStringArray([line, subtitles_dict[index]["text"]]).join(" ")
				index += 1
				
		lines[line_index].bbcode_text = line


func _render_text():
	var share = min(((animation_player.current_animation_position - subtitles_dict[current_index]["start"]) \
				/ (subtitles_dict[current_index]["end"] - subtitles_dict[current_index]["start"])),
					1.0)

	lines[0].bbcode_text = _create_current_line(share)

func _create_current_line(share : float):
	var line = ""
	var index = current_index - 1

	# Part before the current text
	while index >= 0 and subtitles_dict[index]["segment"] == current_segment_id:
		line = subtitles_dict[index]["text"] + " " + line
		index -= 1
	
	line = "[color=#FF0000]" + line
	
	# Current text
	var text_length = subtitles_dict[current_index]["text"].length()
	var substr_length = round(text_length * share)
	
	line += subtitles_dict[current_index]["text"].substr(0, substr_length) + "[/color]"
	line += subtitles_dict[current_index]["text"].substr(substr_length, text_length-substr_length)
	
	# Part after the current text
	index = current_index + 1
	while index < subtitles_dict.size() and subtitles_dict[index]["segment"] == current_segment_id:
		line += " " + subtitles_dict[index]["text"]
		index += 1
	
	return line
