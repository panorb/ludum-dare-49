class_name EvaluationPlayback
extends Playback

func initialize(data, character_name : String):
	self.subtitles = data
	self.subtitles_container.map_subtitles_to_animation(self.subtitles)

	var filepath_recording := "res://Recordings/" + character_name + ".wav"
	self.audio_stream_player.stream = load(filepath_recording)

