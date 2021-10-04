extends GameScene

onready var playback = get_node("Playback")
onready var repeat_choice = get_node("RepeatChoice")
onready var censor_button = get_node("CensorButton")
onready var energy_meter = get_node("EnergyMeter")
onready var evaluation = get_node("Evaluation")

export(int) var energy_regeneration_multiplier = 170
export(int) var energy_depletion_multiplier = 520

var last_ended_chapter := ""
var censor_button_down = false

func _ready():
	playback.load_character("russian-officer")
	censor_button.enabled = false
	_start_chapter("example")
	
	playback.connect("chapter_ended", self, "_on_chapter_playback_ended")
	evaluation.connect("evaluation_finished", self, "_on_chapter_evaluation_finished")

func _process(delta):
	if censor_button_down:
		energy_meter.value -= energy_depletion_multiplier * delta
		
		if energy_meter.value == 0:
			playback.stop_censoring()
	else:
		energy_meter.value +=  energy_regeneration_multiplier * delta
		
		

var censorship_allowed = ["example", "segment-1", "segment-2", "segment-3"]

func _start_chapter(chapter_id):
	evaluation.visible = false
	playback.visible = true
	
	censor_button.enabled = chapter_id in censorship_allowed
	playback.play_chapter(chapter_id)

func _start_evaluation(chapter_id : String, saved_data : Dictionary, character_name : String) -> void:
	playback.visible = false
	evaluation.visible = true
	
	censor_button.enabled = false
	
	evaluation.initialize(saved_data, character_name)
	evaluation.play_chapter(chapter_id)

func _on_chapter_playback_ended(chapter_id : String, saved_data : Dictionary) -> void:
	last_ended_chapter = chapter_id
	
	# Russischer Anfang
	if chapter_id in ["beginning", "instructions"]:
		repeat_choice.present()
	
	if chapter_id == "repeat":
		_start_chapter("instructions")
	
	if chapter_id == "example-intro":
		_start_chapter("example")
	
	if chapter_id == "example":
		_start_evaluation("example", saved_data, "russian-officer")
		
#		# TODO: Auswertung hier einfügen
#		playback.hide()
#		evaluation.initialize(saved_data, "russian-officer")
#		evaluation.play_chapter(chapter_id)
		# TODO: Richtige Voicezeile (Success oder Failure) als Anmerkung des Officers auswählen
		# _start_chapter("example-failure")
	
	if chapter_id == "example-failure":
		repeat_choice.present()
	
	if chapter_id in ["example-success", "good-luck"]:
		# Übergang zum Amerikaner
		playback.load_character("american-spy")
		_start_chapter("segment-1")
	
	# Amerikanisches Hauptspiel
	if chapter_id in ["segment-1", "segment-2", "segment-3"]:
		_start_evaluation(chapter_id, saved_data, "american-spy")

var total_american_penalty := 0

func _on_chapter_evaluation_finished(chapter_id : String, penalty_score : int):
	if chapter_id == "example":
		if penalty_score > 5:
			_start_chapter("example-failure")
		else:
			_start_chapter("example-success")
	
	if chapter_id == "segment-1":
		total_american_penalty += penalty_score
		_start_chapter("segment-2")
	
	if chapter_id == "segment-2":
		total_american_penalty += penalty_score
		_start_chapter("segment-3")
	
	if chapter_id == "segment-3":
		total_american_penalty += penalty_score
		
		playback.load_character("russian-officer")
		if total_american_penalty > 12:
			_start_chapter("ending-bad")
		elif total_american_penalty > 5:
			_start_chapter("ending-neutral")
		else:
			_start_chapter("ending-good")
		

func _on_RepeatChoice_proceed_selected():
	if last_ended_chapter in ["beginning", "instructions"]:
		_start_chapter("example-intro")
	
	if last_ended_chapter == "example-failure":
		_start_chapter("good-luck")


func _on_RepeatChoice_repeat_selected():
	if last_ended_chapter in ["beginning", "instructions"]:
		_start_chapter("repeat")
	
	if last_ended_chapter == "example-failure":
		playback.load_character("russian-officer")
		_start_chapter("example-intro")


func _on_CensorButton_button_down():
	censor_button_down = true
	playback.start_censoring()


func _on_CensorButton_button_up():
	censor_button_down = false
	playback.stop_censoring()
