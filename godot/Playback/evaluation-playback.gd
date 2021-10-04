class_name EvaluationPlayback
extends Playback

func initialize(data, character_name : String):
	subtitles = data
	subtitles_container.map_subtitles_to_animation(subtitles)

	var filepath_recording := "res://Recordings/" + character_name + ".wav"
	audio_stream_player.stream = load(filepath_recording)

