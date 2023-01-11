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

var last_pos : Vector2 = Vector2()
var server_pos : Vector2 = Vector2()

var hooked : bool = false
var hook_weight : Vector2 = Vector2()

var relative_vel : Vector2 = Vector2()
var relative_accel : Vector2 = Vector2()
var time_since_last_packet : float = 0.0
var just_recieved_pos_packet : bool = false

func _ready():
	Global.ball = self
	
func _process(delta):
	relative_accel = (global_position - last_pos) - relative_vel
	relative_vel = global_position - last_pos
	last_pos = global_position
	if Network.is_server:
		gravity_scale = grav_scale
		
		# fix particles so they do not have to use linear_velocity and can use change in position
		$CPUParticles2D.emitting = false
		if relative_vel.length() > MAX_SPEED-500:
			$CPUParticles2D.emitting = true
		
		if max_speed > MAX_SPEED: 
			max_speed -= (MAX_SPEED/2)*delta
			$CPUParticles2D2.emitting = false
			if relative_vel.length() > MAX_SPEED*2-1000:
				$CPUParticles2D2.direction = relative_vel.normalized()
				$CPUParticles2D2.emitting = true
			
		update()
		if not draw:
			$CPUParticles2D.emitting = false
			$CPUParticles2D2.emitting = false
		rpc_unreliable("update_client_pos", global_position)
		if hooked:
			apply_central_impulse(hook_weight * delta)
	else:
		time_since_last_packet += delta
		#global_position += relative_vel
		# estimating that a packet will be every 0.2 seconds
		#global_position += relative_vel * delta * 5.0
#		if just_recieved_pos_packet:
#			global_position = server_pos 
#			just_recieved_pos_packet = false
		global_position = lerp(global_position, server_pos + relative_vel, delta * 20.0)
		
remotesync func recieve_client_hook(new_hook, new_hook_weight):
	hooked = new_hook
	hook_weight = new_hook_weight
	
remote func update_client_pos(new_pos):
	server_pos = new_pos
	just_recieved_pos_packet = true
	
func _physics_process(delta):
	# change to change in position so this doesnt have to be sent over the network
	if Network.is_server:
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
