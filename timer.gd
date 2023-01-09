extends RichTextLabel


func _process(delta):
	bbcode_text = "[center]" + str(int(Global.time/60)) + " : " + str(int(Global.time)%60)
