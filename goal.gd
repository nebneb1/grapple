extends Area2D


export var team_num := 1

var can_score := true

func _process(delta):
	for b in get_overlapping_bodies():
		if b.is_in_group("ball") and can_score:
			b.draw = false
			Global.scoreboard.update_score(team_num, 1)
			can_score = false
			$CPUParticles2D.emitting = true
			Engine.time_scale = 0.5
			Global.active = false
			yield(get_tree().create_timer(1.5), "timeout")
			Engine.time_scale = 1
			Global.players = []
			Global.active = true
			get_tree().reload_current_scene()
			
