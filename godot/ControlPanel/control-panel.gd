extends Control

onready var subtitle_label = get_node("MarginContainer/VBoxContainer/SubtitleLabel")
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

func _ready():
	subtitle_label.connect("text_started", self, "_on_text_started")
	subtitle_label.connect("text_ended", self, "_on_text_ended")
	
	censor_button.connect("button_down", self, "_on_CensorButton_down")
	censor_button.connect("button_up", self, "_on_CensorButton_up")
	
	var filepath_subtitles = "res://Recordings/" + filename_subtitles + ".json"
	subtitles = json_file_parser.parse_file(filepath_subtitles)
	subtitle_label.map_subtitles_to_animation(subtitles)
	
	var filepath_recording = "res://Recordings/" + filename_recording + ".wav"
	audio_stream_player.stream = load(filepath_recording)
	
	subtitle_label.start_subtitles()
	audio_stream_player.play()

func _on_CensorButton_down():
	censor_button_down = true
	if last_index < 0:
		return
	if subtitles[last_index]["status"] == "running":
		subtitles[last_index]["last_pressed"] = OS.get_ticks_msec()

func _on_CensorButton_up():
	censor_button_down = false
	if last_index < 0:
		return
	if subtitles[last_index]["status"] == "running":
		subtitles[last_index]["time_pressed"] = subtitles[last_index]["time_pressed"] \
												+ OS.get_ticks_msec() - subtitles[last_index]["last_pressed"]
		
func _on_text_started(index):
	last_index = index
	subtitles[last_index]["status"] = "running"
	subtitles[last_index]["time_pressed"] = 0
	
	if censor_button_down:
		subtitles[last_index]["last_pressed"] = OS.get_ticks_msec()
	
func _on_text_ended(index):
	subtitles[index]["status"] = "finished"
	
	if censor_button_down:
		subtitles[index]["time_pressed"] = subtitles[index]["time_pressed"] \
												+ OS.get_ticks_msec()- subtitles[index]["last_pressed"]
	
	var coverage = round(subtitles[index]["time_pressed"] \
						/ ((subtitles[index]["end"] - subtitles[index]["start"]) * 100)) * 10
