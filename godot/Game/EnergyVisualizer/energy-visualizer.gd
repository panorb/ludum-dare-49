extends TextureRect

onready var texture_progress = get_node("TextureProgress")

func update_percentage(percentage : int) -> void:
	texture_progress.value = percentage
