extends RichTextLabel


func _process(delta):
	bbcode_text = "[center]" + str(int(get_parent().get_parent().time/60)) + " : " + str(int(get_parent().get_parent().time)%60)
