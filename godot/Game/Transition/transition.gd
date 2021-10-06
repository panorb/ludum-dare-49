extends Control

onready var background = get_node("Background")
onready var section_heading =  get_node("SectionHeading")
onready var section_title_label = get_node("SectionHeading/Title") 
onready var section_description_label = get_node("SectionHeading/Description")
onready var notice_me_player = get_node("NoticeMePlayer")
onready var tween = get_node("Tween")

signal finished

func start(section_tile, section_description, flash):
	self.visible = true
	section_title_label.text = section_tile
	section_description_label.text = section_description
	
	tween.interpolate_property(background, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 0.6), 1.2, Tween.TRANS_EXPO)
	tween.interpolate_property(section_heading, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.8, Tween.TRANS_EXPO)
	tween.start()
	yield(tween, "tween_all_completed")
	
	if flash:
		for _i in range(5):
			notice_me_player.play()
			tween.interpolate_property(section_title_label, "custom_colors/font_color", Color.aqua, Color.white, 0.15)
			tween.start()
			yield(tween, "tween_all_completed")

	tween.interpolate_property(section_heading, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2, Tween.TRANS_EXPO)
	tween.interpolate_property(background, "modulate", Color(1, 1, 1, 0.6), Color(1, 1, 1, 0), 1.6, Tween.TRANS_EXPO)
	tween.start()
	yield(tween, "tween_all_completed")
	
	self.visible = false
	emit_signal("finished")
