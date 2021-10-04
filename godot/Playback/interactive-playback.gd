class_name InteractivePlayback
extends Playback

var censoring : bool = false

func load_character(character_name : String) -> void:
	self.subtitles_container.visible = false
	var filepath_subtitles := "res://Recordings/" + character_name + ".json"
	self.subtitles = self.json_file_parser.parse_file(filepath_subtitles)
	self.subtitles_container.map_subtitles_to_animation(self.subtitles)

	var filepath_recording := "res://Recordings/" + character_name + ".wav"
	self.audio_stream_player.stream = load(filepath_recording)

func start_censoring():
	if censoring:
		return
	
	censoring = true
	self.audio_stream_player.volume_db = -30
	self.white_noise_player.play()   
	
	if self.last_index < 0:
		return
	if self.subtitles["timing"][self.last_index]["status"] == "running":
		_set_start_cursor(self.last_index)	

func stop_censoring():
	if not censoring:
		return
	
	censoring = false
	self.audio_stream_player.volume_db = 0
	self.white_noise_player.stop()
	
	if self.last_index < 0:
		return
	if self.subtitles["timing"][self.last_index]["status"] == "running":
		_set_end_cursor(self.last_index)
	
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
		"start_position": self.subtitles_container.last_cursor_position
	}
	if not "censored_intervals" in self.subtitles["timing"][index].keys():
		self.subtitles["timing"][index]["censored_intervals"] = [censor_interval]
	else:
		self.subtitles["timing"][index]["censored_intervals"].append(censor_interval)
	self.subtitles_container.update_censored_intervals(index, self.subtitles["timing"][index]["censored_intervals"])

func _set_end_cursor(index: int) -> void:
	var cursor_position = self.subtitles_container.last_cursor_position
	
	if self.subtitles["timing"][index]["status"] == "finished":
		cursor_position = self.subtitles["timing"][index]["text"].length()

	self.subtitles["timing"][index]["censored_intervals"][-1]["end_position"] \
		= cursor_position
	self.subtitles_container.update_censored_intervals(index, self.subtitles["timing"][index]["censored_intervals"])


