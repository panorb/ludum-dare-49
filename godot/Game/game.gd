extends Control

onready var playback = get_node("Playback")
onready var repeat_choice = get_node("RepeatChoice")
onready var censor_button = get_node("CensorButton")
onready var energy_meter = get_node("EnergyMeter")

export(int) var energy_regeneration_multiplier = 520
export(int) var energy_depletion_multiplier = 140

var last_ended_chapter := ""
var censor_button_down = false

func _ready():
	playback.load_character("russian-officer")
	censor_button.enabled = false
	playback.play_chapter("example-success")
	
	playback.connect("chapter_ended", self, "_on_chapter_ended")

func _process(delta):
	if censor_button_down:
		energy_meter.value -= energy_regeneration_multiplier * delta
		
		if energy_meter.value == 0:
			playback.stop_censoring()
	else:
		energy_meter.value += energy_depletion_multiplier * delta
		
		

var censorship_allowed = ["example", "segment-1", "segment-2", "segment-3"]

func _start_chapter(chapter_id):
	censor_button.enabled = chapter_id in censorship_allowed
	playback.play_chapter(chapter_id)

func _on_chapter_ended(chapter_id):
	last_ended_chapter = chapter_id
	
	# Russischer Anfang
	if chapter_id in ["beginning", "instructions"]:
		repeat_choice.present()
	
	if chapter_id == "repeat":
		_start_chapter("instructions")
	
	if chapter_id == "example-intro":
		_start_chapter("example")
	
	if chapter_id == "example":
		# TODO: Auswertung hier einfügen
		# TODO: Richtige Voicezeile (Success oder Failure) als Anmerkung des Officers auswählen
		_start_chapter("example-failure")
	
	if chapter_id == "example-failure":
		repeat_choice.present()
	
	if chapter_id == "example-success":
		# TODO: Übergang zum Amerikaner
		playback.load_character("american-spy")
		_start_chapter("segment-3")
	
	# Amerikanisches Hauptspiel
	if chapter_id == "segment-1":
		# TODO: Auswertung hier einfügen
		_start_chapter("segment-2")
	
	if chapter_id == "segment-2":
		# TODO: Auswertung hier einfügen
		_start_chapter("segment-3")
	
	if chapter_id == "segment-3":
		# TODO: Richtiges Ending je nach Penalityanzahl wählen
		playback.load_character("russian-officer")
		_start_chapter("ending-wtf")

func _on_RepeatChoice_proceed_selected():
	if last_ended_chapter in ["beginning", "instructions"]:
		_start_chapter("example-intro")
	
	if last_ended_chapter == "example-failure":
		# TODO: Übergang zum Amerikaner
		playback.load_character("american-spy")
		_start_chapter("segment-1")


func _on_RepeatChoice_repeat_selected():
	if last_ended_chapter in ["beginning", "instructions"]:
		_start_chapter("repeat")
	
	if last_ended_chapter == "example-failure":
		_start_chapter("example-intro")


func _on_CensorButton_button_down():
	censor_button_down = true
	playback.start_censoring()


func _on_CensorButton_button_up():
	censor_button_down = false
	playback.stop_censoring()
