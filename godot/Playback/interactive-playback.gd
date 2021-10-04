class_name InteractivePlayback
extends Playback

var censoring : bool = false

func load_character(character_name : String) -> void:
	var filepath_subtitles := "res://Recordings/" + character_name + ".json"
	subtitles = json_file_parser.parse_file(filepath_subtitles)
	subtitles_container.map_subtitles_to_animation(subtitles)

	var filepath_recording := "res://Recordings/" + character_name + ".wav"
	audio_stream_player.stream = load(filepath_recording)

func _ready():
	._ready()
	load_character("russian-officer")
	play_chapter("good-luck")

func start_censoring():
	censoring = true
	audio_stream_player.volume_db = -30
	white_noise_player.play()   
	
	if last_index < 0:
		return
	if subtitles["timing"][last_index]["status"] == "running":
		_set_start_cursor(last_index)	

func stop_censoring():
	censoring = false
	audio_stream_player.volume_db = 0
	white_noise_player.stop()
	
	if last_index < 0:
		return
	if subtitles["timing"][last_index]["status"] == "running":
		_set_end_cursor(last_index)
	
func _on_text_started(index):
	._on_text_started(index)

	if censoring:
		_set_start_cursor(index)
	
func _on_text_ended(index):
	._on_text_ended(index)

	if censoring:
		_set_end_cursor(index)

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
	var cursor_position = subtitles_container.last_cursor_position
	
	if subtitles["timing"][index]["status"] == "finished":
		cursor_position = subtitles["timing"][index]["text"].length()

	subtitles["timing"][index]["censored_intervals"][-1]["end_position"] \
		= cursor_position
	subtitles_container.update_censored_intervals(index, subtitles["timing"][index]["censored_intervals"])


