extends Control

onready var subtitles_container = get_node("MarginContainer/SubtitlesContainer")
onready var json_file_parser = get_node("JsonFileParser")
onready var audio_stream_player = get_node("AudioStreamPlayer")
onready var white_noise_player = get_node("WhiteNoisePlayer")

export(String) var filename_subtitles
export(String) var filename_recording

var subtitles = null
var censoring : bool = false
var last_index : int = -1
var timestamp = null
var time_pressed : float = 0.0

var current_chapter = ""

signal text_ended(timing)
signal chapter_ended(chapter_id)
signal information_passed(information_name, timings_index)

var chapter_ended_signal_sended = false

func load_character(character_name : String) -> void:
	var filepath_subtitles := "res://Recordings/" + character_name + ".json"
	subtitles = json_file_parser.parse_file(filepath_subtitles)
	subtitles_container.map_subtitles_to_animation(subtitles)

	var filepath_recording := "res://Recordings/" + character_name + ".wav"
	audio_stream_player.stream = load(filepath_recording)

func play_chapter(chapter_id : String) -> void:
	assert(chapter_id in subtitles["chapter"])
	var start_position = subtitles["chapter"][chapter_id]["start"]

	audio_stream_player.play(start_position)
	subtitles_container.start_subtitles(start_position)
	
	current_chapter = chapter_id
	chapter_ended_signal_sended = false

func _process(_delta):
	var end_position = 0.0
	
	if current_chapter:
		end_position = subtitles["chapter"][current_chapter]["end"]

	if audio_stream_player.get_playback_position() >= end_position:
		subtitles_container.stop_subtitles()
		
		if audio_stream_player.playing:
			audio_stream_player.stop()
		
		if not chapter_ended_signal_sended:
			chapter_ended_signal_sended = true
			emit_signal("chapter_ended", current_chapter)

func _ready():
	subtitles_container.connect("text_started", self, "_on_text_started")
	subtitles_container.connect("text_ended", self, "_on_text_ended")

	load_character("russian-officer")
	play_chapter("good-luck")

func start_censoring():
	if censoring:
		return
	
	censoring = true
	audio_stream_player.volume_db = -30
	white_noise_player.play()
	
	if last_index < 0:
		return
	if subtitles["timing"][last_index]["status"] == "running":
		_set_start_cursor(last_index)	

func stop_censoring():
	if not censoring:
		return
	
	censoring = false
	audio_stream_player.volume_db = 0
	white_noise_player.stop()
	
	if last_index < 0:
		return
	if subtitles["timing"][last_index]["status"] == "running":
		_set_end_cursor(last_index)
	
func _on_text_started(index):
	last_index = index
	subtitles["timing"][last_index]["status"] = "running"
	
	if censoring:
		_set_start_cursor(index)
	
func _on_text_ended(index):
	subtitles["timing"][index]["status"] = "finished"
	
	if censoring:
		_set_end_cursor(index)
	
	emit_signal("text_ended", subtitles["timing"][index])
	if "information" in subtitles["timing"][index]:
		emit_signal("information_passed", subtitles["timing"][index]["information"], index)

func _set_start_cursor(index: int) -> void:
	var censor_interval = {
		"start_position": subtitles_container.last_cursor_position
	}
	if not "censored_intervals" in subtitles["timing"][index].keys():
		subtitles["timing"][index]["censored_intervals"] = [censor_interval]
	else:
		subtitles["timing"][index]["censored_intervals"].append(censor_interval)
	subtitles_container.update_censored_intervals(index, subtitles["timing"][index]["censored_intervals"])

func _set_end_cursor(index: int) -> void:
	print("CALLED")
	var cursor_position = subtitles_container.last_cursor_position
	
	if subtitles["timing"][index]["status"] == "finished":
		cursor_position = subtitles["timing"][index]["text"].length()

	subtitles["timing"][index]["censored_intervals"][-1]["end_position"] \
		= cursor_position
	subtitles_container.update_censored_intervals(index, subtitles["timing"][index]["censored_intervals"])
