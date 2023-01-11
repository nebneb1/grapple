extends KinematicBody2D

export var player_num := 0

const max_speed := 8.0
const dash_regen_rate := 2.5
const max_dashes := 3
const dash_speed := 30.0
const ring_size := 400.0
const PULL_SPEED := 10.0
const MAX_HOOKTIME := 2.5

var dashes := 0
var hooked := false setget set_hooked
var dash_timer = 0.0
var hook_timer = 0.0
var velocity := Vector2.ZERO
var color = Color(0,0,0)
var radius := 20.0
var accel := 5.0
var ACCEL := accel

#anims--
var circle_rotation := 0.0
const lines = 32.0
var superficial_hooked : bool = false

func _ready():
	set_network_master(Network.players.keys()[player_num])
		
	Global.players.append([player_num, self])
	if is_network_master():
		$Label.text = Network.username
		rpc('set_username', Network.username)
		
remote func set_username(new_name):
	$Label.text = new_name
	
func _physics_process(delta):
	if is_network_master():
		dash_timer += delta
		if dash_timer >= dash_regen_rate:
			if dashes < max_dashes:
				dashes += 1
			dash_timer = 0.0
		
		
		var dir: Vector2
		dir.x = int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left"))
		dir.y = int(Input.is_action_pressed("down"))-int(Input.is_action_pressed("up"))
		accel = ACCEL
		if hooked: accel = ACCEL*3
		velocity = lerp(velocity, dir.normalized()*max_speed, delta*accel)
		
		if global_position.distance_to(Global.ball.position) <= ring_size+Global.ball.radius:
			Global.ball.can_hit = true
		
		if hooked:
			Global.ball.rpc_unreliable_id(1, 'recieve_client_hook', true, ((global_position-Global.ball.global_position)*PULL_SPEED/500))
			# velocity for player, this is fine
			velocity += (Global.ball.global_position-global_position)*PULL_SPEED*delta/100
			
			#timing ball
			hook_timer += delta
			# disconnecting ball
			if global_position.distance_to(Global.ball.position) <= radius+Global.ball.radius or hook_timer >= MAX_HOOKTIME:
				set_hooked(false)
				
			Global.ball.circle_rotation += 5
			Global.ball.can_hit = true
			Global.ball.hit_color = Color(0.75, 0.0, 0.0, 1)
		else:
			hook_timer = clamp(hook_timer-delta, 0, MAX_HOOKTIME)
		
		move_and_collide(velocity*144*delta)
		
		circle_rotation += 0.5
		rpc_unreliable("update_player_pos", global_position)
#	if hooked:
	update()

func set_hooked(new_val):
	hooked = new_val
	rset('superficial_hooked', hooked)
	Global.ball.rpc_id(1, 'recieve_client_hook', hooked, Vector2())
	
remote func update_player_pos(new_pos):
	global_position = new_pos
	
func _input(event):
	if !is_network_master():
		return
	if event.is_action_pressed("dash") and dashes > 0:
		dashes -= 1
		velocity = velocity.normalized()*dash_speed
		if hooked:
			Global.ball.rset_id(1, 'max_speed', Global.ball.max_speed * 2)
			velocity *= 3
		dash_timer = 0.0
	
	if Input.is_action_just_pressed("hook") and global_position.distance_to(Global.ball.position) <= ring_size+Global.ball.radius:
		for plr in Global.players:
			if plr[1].hooked:
				plr[1].set_hooked(false)
		set_hooked(true)
		
	if event.is_action_released("hook"):
		set_hooked(false)

func _draw():
	if hooked:
		draw_line(Vector2.ZERO, Global.ball.global_position-global_position, Color(1,1,1), 5, true)
		# no idea why the number 144 works
		draw_arc(Vector2.ZERO, radius+40, 0, deg2rad(144*(MAX_HOOKTIME-hook_timer)), 128, Color(1, (MAX_HOOKTIME-hook_timer), (MAX_HOOKTIME-hook_timer), 0.5), 2, true)
		
	draw_circle(Vector2.ZERO, radius, color)
	
	if circle_rotation >= 360: circle_rotation = 0
	for i in range(lines):
		if i%2 == 0:
			draw_arc(Vector2.ZERO, ring_size, deg2rad(i*360.0/lines+circle_rotation), deg2rad((i+1)*360.0/lines+circle_rotation), 5, Color(0.5, 0.5, 0.5, 0.25), 3, true)
	
	var count = 0
	for i in range(max_dashes*2):
		if i%2 == 0:
			count += 1
			if count <= dashes:
				draw_arc(Vector2.ZERO, radius+20, deg2rad(i*30/max_dashes*2.0-90), deg2rad((i+1)*30/max_dashes*2.0-90), 40, Color(0.0, 0, 0), 3, true)
			
			

func change_dash(num = 1):
	if num > 0:
		pass
	elif num < 0:
		pass
	
	else: return
