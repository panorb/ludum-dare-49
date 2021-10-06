class_name Playback
extends Node

onready var subtitles_container = get_node("MarginContainer/VBoxContainer/SubtitlesContainer")
onready var json_file_parser = get_node("JsonFileParser")
onready var audio_stream_player = get_node("AudioStreamPlayer")
onready var white_noise_player = get_node("WhiteNoisePlayer")

var subtitles = null
var last_index : int = -1
var current_chapter = ""
var chapter_ended_signal_sended = false

var censoring : bool = false

signal text_ended(timing)
signal chapter_ended(chapter_id)
signal information_passed(timing, timings_index)

func play_chapter(chapter_id : String) -> void:
	assert(chapter_id in subtitles["chapter"])
	var start_position = subtitles["chapter"][chapter_id]["start"]

	audio_stream_player.play(start_position)
	subtitles_container.start_subtitles(chapter_id)
	
	current_chapter = chapter_id
	chapter_ended_signal_sended = false

func start_censoring():
	if censoring:
		return
	censoring = true
	self.audio_stream_player.volume_db = -30
	# self.white_noise_player.play()   

func stop_censoring():
	if not censoring:
		return
	censoring = false
	self.audio_stream_player.volume_db = 0
	# self.white_noise_player.stop()
	

func _process(_delta):
	var end_position = 0.0
	
	if current_chapter and current_chapter in subtitles["chapter"]:
		end_position = subtitles["chapter"][current_chapter]["end"]

	if audio_stream_player.get_playback_position() >= end_position:
		subtitles_container.stop_subtitles()
		
		if audio_stream_player.playing:
			audio_stream_player.stop()
		
		if not chapter_ended_signal_sended:
			chapter_ended_signal_sended = true
			emit_signal("chapter_ended", current_chapter, subtitles)
	
	if not censoring and white_noise_player.playing:
		white_noise_player.stop()
	
	if censoring and not white_noise_player.playing:
		white_noise_player.play()

func _ready():
	subtitles_container.connect("text_started", self, "_on_text_started")
	subtitles_container.connect("text_ended", self, "_on_text_ended")


func _on_text_started(index):
	subtitles_container.visible = true
	last_index = index
	subtitles["timing"][last_index]["status"] = "running"
	
func _on_text_ended(index):
	subtitles["timing"][index]["status"] = "finished"
	emit_signal("text_ended", subtitles["timing"][index])
	if "information" in subtitles["timing"][index]:
		emit_signal("information_passed", subtitles["timing"][index], index)
