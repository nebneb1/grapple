extends RigidBody2D

const radius := 60.0
const MAX_SPEED := 2000.0
var max_speed := 2000.0

var circle_rotation = 0
var can_hit := false
var color := Color(0,0,0)
var hit_color = Color(0.0, 0.75, 0.75, 1)
var grav_scale = gravity_scale
var draw := true

func _ready():
	Global.ball = self
	
func _process(delta):
	gravity_scale = grav_scale
	
	$CPUParticles2D.emitting = false
	if linear_velocity.length() > MAX_SPEED-500:
		$CPUParticles2D.emitting = true
	
	if max_speed > MAX_SPEED: 
		max_speed -= (MAX_SPEED/2)*delta
		$CPUParticles2D2.emitting = false
		if linear_velocity.length() > MAX_SPEED*2-1000:
			$CPUParticles2D2.direction = linear_velocity.normalized()
			$CPUParticles2D2.emitting = true
		
	update()
	if not draw:
		$CPUParticles2D.emitting = false
		$CPUParticles2D2.emitting = false

func _physics_process(delta):
	if linear_velocity.length() > max_speed:
		apply_central_impulse(-linear_velocity.normalized()*delta*((linear_velocity.length()-max_speed)/100))
#		color.r += 0.02
	
	else:
		pass
#		color.r -= 0.005
	
	circle_rotation += 1
	

func _draw():
	if draw:
		draw_circle(Vector2.ZERO, radius, color)
		if can_hit:
			can_hit = false
			for i in range(8):
				if i%2 == 0:
					draw_arc(Vector2.ZERO, radius+10, deg2rad(i*360.0/8+circle_rotation), deg2rad((i+1)*360.0/8+circle_rotation), 10, hit_color, 3, true)
			
			hit_color = Color(0.0, 0.75, 0.75, 1)
