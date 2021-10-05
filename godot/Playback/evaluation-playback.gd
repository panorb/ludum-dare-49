class_name EvaluationPlayback
extends Playback

func _ready():
	subtitles_container.connect("text_censored_start", self, "start_censoring")
	subtitles_container.connect("text_censored_end", self, "stop_censoring")

func initialize(data, character_name : String):
	self.subtitles = data
	self.subtitles_container.map_subtitles_to_animation(self.subtitles)

	var filepath_recording := "res://Recordings/" + character_name + ".wav"
	self.audio_stream_player.stream = load(filepath_recording)

