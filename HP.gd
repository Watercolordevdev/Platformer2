extends Label

func _process(_delta):
	text = "HP:" + str(get_node("../../Player").health)
