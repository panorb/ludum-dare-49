extends VBoxContainer

signal text_started
signal text_ended(elapsed_time)

var subtitles_dict : Array = []
var animation_name : String = "Subtitles"
var current_animation : Animation = null
var method_track_index_start : int = 0
var method_track_index_end : int = 1
var current_segment_id: int = -1
var current_index : int = 0
var preset_formatting : Dictionary = {}
var last_cursor_position : int = 0 

onready var animation_player = get_node("AnimationPlayer")
onready var lines = [get_node("Line1"), get_node("Line2"), get_node("Line3")]

func _ready():
	animation_player.connect("text_started", self, "_on_text_started")
	animation_player.connect("text_ended", self, "_on_text_ended")

func _process(_delta):
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

func update_censored_intervals(index : int, censored_intervals : Array):
	if not subtitles_dict:
		return
	if index >= subtitles_dict.size():
		return
	
	subtitles_dict[index]["censored_intervals"] = censored_intervals

func start_subtitles(from_position : float = 0.0):
	animation_player.set_current_animation(animation_name)
	animation_player.seek(from_position)
	animation_player.play()

func stop_subtitles() -> void:
	animation_player.stop()

func preset_subtitle_formatting(formatting : Array):
	for setting in formatting:
		assert("index" in setting)
		var index = setting["index"]
		preset_formatting[index] = {}
		
		if "color" in setting.keys():
			preset_formatting[index]["color"] = setting["color"]
	
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
	last_cursor_position = 0
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
				subtitles_dict[index]["segment"] == current_segment_id + line_index:
				
				var text_element = subtitles_dict[index]["text"]
				var formatted_text_element = text_element
				
				if "censored_intervals" in subtitles_dict[index].keys():
					formatted_text_element = ""
					
					for i in len(text_element):
						var c = text_element[i]
						
						if _is_censored(i, subtitles_dict[index]["censored_intervals"]):
							formatted_text_element += "[color=#000F00]" + c + "[/color]"
						else:
							formatted_text_element += c
				
				line = PoolStringArray([line, formatted_text_element]).join(" ")
				index += 1
				
		lines[line_index].bbcode_text = "[center]" + line + "[/center]"

func _is_censored(index, intervals):
	for interval in intervals:
		if "end_position" in interval:
			if index >= interval["start_position"] and index <= interval["end_position"]:
				return true
		else:
			if index >= interval["start_position"] and index <= last_cursor_position:
				return true
		
	return false

func _render_text():
	if not animation_player.is_playing():
		return
	
	var share = min(((animation_player.current_animation_position - subtitles_dict[current_index]["start"]) \
				/ (subtitles_dict[current_index]["end"] - subtitles_dict[current_index]["start"])),
					1.0)
	
	var text_length = subtitles_dict[current_index]["text"].length()
	var new_cursor_position = round(text_length * share)
	
	if new_cursor_position != last_cursor_position:
		last_cursor_position = new_cursor_position
		_update_current_line()

func _update_current_line():
	var line = ""
	var index = max(current_index - 1, 0)
	
	# Find first text elment of segment
	while index >= 0 and subtitles_dict[index]["segment"] == current_segment_id:
		index -= 1
	
	if index < 0 or subtitles_dict[index]["segment"] != current_segment_id:
		index += 1
	
	if subtitles_dict[index]["segment"] != current_segment_id:
		return
	
	while subtitles_dict[index]["segment"] == current_segment_id:
		var text_element = subtitles_dict[index]["text"]
		var formatted_text_element = ""

		for i in len(text_element):
			var c = text_element[i]
			
			if "censored_intervals" in subtitles_dict[index].keys() and \
				_is_censored(i, subtitles_dict[index]["censored_intervals"]):
				formatted_text_element += "[color=#000F00]" + c + "[/color]"
			elif index < current_index:
				formatted_text_element +=  "[color=#FF0000]" + c + "[/color]"
			elif index == current_index and i < last_cursor_position:
				formatted_text_element +=  "[color=#FF0000]" + c + "[/color]"
			else:
				formatted_text_element += c

		line = PoolStringArray([line, formatted_text_element]).join(" ")
		index += 1
	
	lines[0].bbcode_text = "[center]" + line + "[/center]"
