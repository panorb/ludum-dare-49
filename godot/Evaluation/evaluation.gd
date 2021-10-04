extends Control

onready var playback = get_node("Playback")
onready var leaked_information_label = get_node("LeakedInformationLabel")

var available_information : Dictionary = {}
var hidden_information : Dictionary = {}
var leaked_information : Dictionary = {}

func _ready():
	playback.connect("information_passed", self, "_on_information_passed")

func initialize(data):
	# Add all information
	for information_name in data["information"].keys():
		var information = data["information"][information_name]
		information["timings_left"] = []
		information["timings_passed"] = []
		available_information[information_name] = information

	# Map the corresponding indices of timing
	for index in data["timings"].size():
		if "information" in data["timings"][index]:
			var information_name = data["timings"][index]["information"]
			available_information[information_name]["timings_left"].append(index)

	for information_name in available_information.keys():
		if "barrier" in available_information[information_name]:
			available_information[information_name]["censor_points"] = 0

func play_chapter(chapter_id : String) -> void:
	playback.play_chapter(chapter_id)

func _on_information_passed(timing, index):
	var information_name = timing["information"]
	if not information_name in available_information.keys():
		return
	
	if not index in available_information[information_name]["timings_left"]:
		return
	
	available_information[information_name]["timings_left"].erase(index)
	available_information[information_name]["timings_passed"].append(index)
	
	available_information[information_name]["censor_points"] += _get_censor_points(timing)
	
	if available_information[information_name]["timings_left"].empty():
		_information_completed(information_name)

func _information_completed(information_name):
	if not information_name in available_information:
		return

	if _was_leaked(information_name):
		_leak_information(information_name)
	else:
		_hide_information(information_name)
	
	# Check for other leaked information
	for information in available_information:
		if _was_leaked(information):
			_leak_information(information)


func _was_leaked(information_name):
	if information_name in leaked_information:
		return true
	
	if information_name in hidden_information:
		return false
	
	var information = available_information[information_name]
	
	if "barrier" in information:
		if not information["timings_left"].empty():
			return false
		if information["censor_points"] >= information["barrier"]:
			return true
		else:
			return false

	elif "requires" in information:
		for requirement in information["requires"]:
			if requirement in available_information or requirement in hidden_information:
				return false

		return true 
	
func _get_censor_points(timing):
	if not "censored_intervals" in timing:
		return 0
	var sum = 0
	for interval in timing["censored_interval"]:
		sum += interval["end_position"] - interval["start_position"]
	
	var percentage = (sum / (timing["end"] - timing["start"])) * 100
	var censor_points = percentage
	if "multiplier" in timing:
		censor_points = timing["multiplier"] * censor_points
	return censor_points

func _leak_information(information_name):
	var information = available_information[information_name]
	available_information.erase(information_name)
	leaked_information[information_name] = information

	leaked_information_label.bbcode_text = information["message"]

func _hide_information(information_name):
	var information = available_information[information_name]
	available_information.erase(information_name)
	hidden_information[information_name] = information
