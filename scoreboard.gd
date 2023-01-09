extends RichTextLabel

onready var scores = Global.scores

func _ready():
	Global.scoreboard = self
	bbcode_text = "[center]" + str(scores[0]) + " - " + str(scores[1])
	
func update_score(goal_num : int, ammount: int):
	scores[goal_num-1] += ammount
	bbcode_text = "[center]" + str(scores[0]) + " - " + str(scores[1])
