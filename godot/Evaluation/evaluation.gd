extends Control

onready var playback = get_node("Playback")

var available_information : Dictionary = {}
var hidden_information : Dictionary = {}
var leaked_information : Dictionary = {}

func _ready():
	playback.connect("information_passed", "_on_information_passed")

func initialize(data):
	# Add all information
	for information_name in data["information"].keys():
		data["information"][information_name]["timings_left"] = []
		data["information"][information_name]["timings_passed"] = []
		available_information[information_name] = data["information"][information_name]
	
	# Map the corresponding indices of timing
	for index in data["timings_left"].size():
		if "information" in data["timings_left"][index]:
			var information_name = data["timings_left"][index]["information"]
			available_information[information_name]["timings_left"].append(index)

	for information_name in available_information.keys():
		if not "barrier" in available_information[information_name]:
			continue
		var total_length = 0
		for index in available_information[information_name]:
			total_length += data["timings_left"][index]["text"].length()
		
		available_information[information_name]["total_length"] = total_length
		available_information[information_name]["censor_length"] = 0.0

func get_leaked_information(data):
	assert("timings" in data)
	for timing in data["timings_left"]:
		if not "information" in timing:
			continue
		var information = data["information"][timing["information"]]
		var percentage_leaked = _get_percentage_of_leaked_information(timing)
		
		if information["barrier"] <= percentage_leaked:
			leaked_information.append(information)
	
	_get_implicit_information()

func _get_percentage_of_leaked_information(information_name):
	var length_censored = 0.0
	if "censored_intervals" in timing:
		for censored_interval in timing["censored_intervals"]:
			length_censored += censored_interval["end_position"] - censored_interval["start_position"]

	
	var percentage = round(length_censored / timing["text"].length() * 100)
	return percentage
		
func _on_information_passed(information_name, index):
	if not information_name in available_information.keys():
		return
	
	if not index in available_information[information_name]["timings_left"]:
		return
	
	available_information[information_name]["timings_left"].erase(index)
	available_information[information_name]["timings_passed"].append(index)
	
	if available_information[information_name]["timings_left"].empty():
		_information_completed(information_name)

func _information_completed(information_name):
	if not information_name in available_information:
		return

	var information = available_information[information_name]
	
func _was_leaked(information_name):
	if information_name in hidden_information:
		return false
		
	if information_name in leaked_information:
		return true
	
	if not information_name in available_information or not available_information[information_name]["timings_left"].empty():
		return false
	
	if "barrier" in information_name:
		_get_percentage_of_leaked_information(information_name)
	
