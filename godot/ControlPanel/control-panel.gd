extends Control

onready var subtitles_label = get_node("MarginContainer/SubtitlesLabel")
onready var json_file_parser = get_node("JsonFileParser")
onready var audio_stream_player = get_node("AudioStreamPlayer")

export(String) var filename_subtitles
export(String) var filename_recording

func _ready():
	var filepath_subtitles = "res://Recordings/" + filename_subtitles + ".json"
	var subtitles = json_file_parser.parse_file(filepath_subtitles)
	subtitles_label.map_subtitles_to_animation(subtitles)
	subtitles_label.start_subtitles()
	
	var filepath_recording = "res://Recordings/" + filename_recording + ".flac"
	audio_stream_player.stream = load(filepath_recording)
	audio_stream_player.play()
