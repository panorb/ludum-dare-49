extends Control

onready var subtitles_container = get_node("MarginContainer/VBoxContainer/SubtitlesContainer")
onready var json_file_parser = get_node("JsonFileParser")
onready var audio_stream_player = get_node("AudioStreamPlayer")
onready var censor_button = get_node("MarginContainer/VBoxContainer/CensorButton")

export(String) var filename_subtitles
export(String) var filename_recording

var subtitles = null
var censor_button_down : bool = false
var last_index : int = -1
var timestamp = null
var time_pressed : float = 0.0
var intervals_pressed = []
var current_censor_interval = {}

func _ready():
	subtitles_container.connect("text_started", self, "_on_text_started")
	subtitles_container.connect("text_ended", self, "_on_text_ended")
	
	censor_button.connect("button_down", self, "_on_CensorButton_down")
	censor_button.connect("button_up", self, "_on_CensorButton_up")
	
	var filepath_subtitles = "res://Recordings/" + filename_subtitles + ".json"
	subtitles = json_file_parser.parse_file(filepath_subtitles)
	subtitles_container.map_subtitles_to_animation(subtitles)
	
	var filepath_recording = "res://Recordings/" + filename_recording + ".wav"
	audio_stream_player.stream = load(filepath_recording)
	
	subtitles_container.start_subtitles()
	audio_stream_player.play()

func _on_CensorButton_down():
	censor_button_down = true
	if last_index < 0:
		return
	if subtitles["timing"][last_index]["status"] == "running":
		subtitles["timing"][last_index]["last_pressed"] = OS.get_ticks_msec()
		_set_start_cursor(last_index)
	subtitles_container.censor_button_pressed = true
	

func _on_CensorButton_up():
	censor_button_down = false
	if last_index < 0:
		return
	if subtitles["timing"][last_index]["status"] == "running":
		subtitles["timing"][last_index]["time_pressed"] = subtitles["timing"][last_index]["time_pressed"] \
												+ OS.get_ticks_msec() - subtitles["timing"][last_index]["last_pressed"]
		_set_end_cursor(last_index)
	subtitles_container.censor_button_pressed = false
	
func _on_text_started(index):
	last_index = index
	subtitles["timing"][last_index]["status"] = "running"
	subtitles["timing"][last_index]["time_pressed"] = 0
	
	if censor_button_down:
		subtitles["timing"][last_index]["last_pressed"] = OS.get_ticks_msec()
		_set_start_cursor(index)
	
func _on_text_ended(index):
	subtitles["timing"][index]["status"] = "finished"
	
	if censor_button_down:
		subtitles["timing"][index]["time_pressed"] = subtitles["timing"][index]["time_pressed"] \
												+ OS.get_ticks_msec()- subtitles["timing"][index]["last_pressed"]
		_set_end_cursor(index)
	
	var coverage = round(subtitles["timing"][index]["time_pressed"] \
						/ ((subtitles["timing"][index]["end"] - subtitles["timing"][index]["start"]) * 100)) * 10

	print(subtitles["timing"][index])

func _set_start_cursor(index: int) -> void:
	var censor_interval = {
		"start_position": subtitles_container.last_cursor_position
	}
	if not "censor_intervals" in subtitles["timing"][index].keys():
		subtitles["timing"][index]["censor_intervals"] = [censor_interval]
	else:
		subtitles["timing"][index]["censor_intervals"].append(censor_interval)
	
func _set_end_cursor(index: int) -> void:
	var cursor_position = subtitles_container.last_cursor_position
	
	if subtitles["timing"][index]["status"] == "finished":
		cursor_position = subtitles["timing"][index]["text"].length()
	
	subtitles["timing"][index]["censor_intervals"][-1]["end_position"] \
		= cursor_position
