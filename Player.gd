# fine numbers
# camera translation.z 6.046

# toodoo
# find a solution to jitter sliding down the slopes (coyotetime lets us jump but jitter is still there)
# bug. it is possible to jump and then stack the velocity by jumping again shortly after within COYOTETIME
# maybe when landing on the ground actually squish the collision capsule

extends KinematicBody
 
const WALK_SPEED = 160
const WALK_ACCEL = 16
const MOVE_SPEED = 12 + 4
const MAX_SPEED = 18
const MAX_DASH_SPEED = 100
const JUMP_FORCE = 30
#const GRAVITY = 0.98
const GRAVITY = 1.5
const MAX_FALL_SPEED = 30
const GROUND_FRICTION = 1
const AIR_FRICTION = 1
const DASH_FRICTION = 250
const STOP_MAG = 0.01

const DASH_ACCEL = 175 - 75 - 50

const COYOTETIME = 0.135 #seconds
var time_after_grounded = 0.0
var is_in_air = false

const JUMP_BUFFER_TIME = 0.160
var time_after_space = JUMP_BUFFER_TIME
const JUMP_CANCEL_MIN_TIME = 0.010
var time_after_space_release = 0.0
var is_jump_canceled = true
 
const H_LOOK_SENS = 0.04
const V_LOOK_SENS = 0.04

const CAM_SWIVEL_CAP = 6
var cam_swivel = 0
 
onready var cambase = $CamBase
onready var anim = $Graphics/AnimationPlayer
onready var anicam = $Graphics/AnimationCamera
onready var infou = $Infou
onready var landaudio = $LandAudio

 
var y_velo = 0
#var accel = Vector3.ZERO
var walk_speed_cap = 22
var dash_speed_cap = 50
#var speed_cap = walk_speed_cap
var speed_cap = MAX_SPEED
var dashes_max = 1
var dashes_left = dashes_max

var air_temp_friction = AIR_FRICTION
var ground_temp_friction = GROUND_FRICTION

var time_after_dash = 0.000
var dash_duration = 0.600
var dash_cooldown = 0.175
var dash_jump_boost_window = 0.225
var dash_jump_boost_k = 2.0

var score = 0
 

#var g = map(30, 0,90 0,1)
# second value must not be negative
func range2range(n : float, a, b, x, y):
#	var range1 = b - a
#	var range2 = y - x
#	print_debug('range1 ', range1)
#	print_debug('range2 ', range2)
#	var res = x + (n / range1) * range2
#	return res
	return x + (y - x) * ((n - a) / (b - a));

func _ready():
	anim.get_animation("walk").set_loop(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	print_debug('range2range(30, 0,90, 10,30) ', range2range(30, 0,90, 10,30))
	print_debug('range2range(0, -90,90, 10,30) ', range2range(0, -90,90, 10,30))
 
func _input(event):
	if event is InputEventMouseMotion:
		cambase.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cambase.rotation_degrees.x = clamp(cambase.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
	
var move_vec = Vector3()
var is_land_played = true
func _physics_process(delta):
	infou.text = ''
	

	
	var accel = Vector3.ZERO

#	var move_vec = Vector3()
	
#	if Input.is_action_pressed("move_forwards"):
#		move_vec.z -= 1
#	if Input.is_action_pressed("move_backwards"):
#		move_vec.z += 1
#	if Input.is_action_pressed("move_right"):
#		move_vec.x += 1
#	if Input.is_action_pressed("move_left"):
#		move_vec.x -= 1
#	move_vec = move_vec.normalized()
#	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
#	move_vec *= MOVE_SPEED
#	move_vec.y = y_velo
	cambase.rotation_degrees.z = 0
	if Input.is_action_pressed("move_forwards"):
		accel.z -= 1 * WALK_ACCEL
	if Input.is_action_pressed("move_backwards"):
		accel.z += 1 * WALK_ACCEL
	if Input.is_action_pressed("move_right"):
		accel.x += 1 * WALK_ACCEL
		cam_swivel = lerp(cam_swivel, -CAM_SWIVEL_CAP, 0.1)
	if Input.is_action_pressed("move_left"):
		accel.x -= 1 * WALK_ACCEL
		cam_swivel = lerp(cam_swivel, CAM_SWIVEL_CAP, 0.1)
	cam_swivel = lerp(cam_swivel, 0.0, 0.1)
	cambase.rotation_degrees.z = cam_swivel
	accel = accel.normalized() * WALK_SPEED# * delta
	accel = accel.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec += accel
#	move_vec = move_vec.normalized()
#	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
#	move_vec *= MOVE_SPEED
#	move_vec = clamp(a, -20, 20)
#	var v_min = move_vec.normalized() * 1
#	var v_max = move_vec.normalized() * 10
#	move_vec = move_vec.clamp(v_min, v_max)
	var move_vec_mag = move_vec.length()
#	if move_vec_mag < STOP_MAG:
#		move_vec = Vector3.ZERO
#	if is_on_floor() and move_vec and move_vec_mag > walk_speed_cap:
#		move_vec = move_vec / (move_vec_mag / speed_cap)
	if move_vec and move_vec_mag > speed_cap:
		move_vec = move_vec / (move_vec_mag / speed_cap)

	
	move_vec.y = y_velo
#	$MoveSpeed.text = 'move_vec ' + str(move_vec.x) +

	if Input.is_action_just_pressed("dash") and dashes_left > 0 and time_after_dash > dash_cooldown:
		# only teleports along x and z axes
		var dash_vec = Vector3.FORWARD.rotated(Vector3(0, 1, 0), rotation.y)
#		dash_vec = dash_vec.rotated(Vector3(dash_vec.x, 0, dash_vec.z), range2range(cambase.rotation_degrees.x, -90, 90, -1, 1))
#		dash_vec.y = cambase.rotation_degrees.x * 0.1
		print('cambase rotdeg.x ', cambase.rotation_degrees.x)
		print_debug('print debug rotdeg.x ', cambase.rotation_degrees.x)
		dash_vec = dash_vec.normalized() * DASH_ACCEL
		
#		move_vec += Vector3.FORWARD.rotated(Vector3(0, 1, 0), rotation.y) * DASH_ACCEL
#		move_vec.x += cambase.rotation.x * DASH_ACCEL
#		move_vec.y += cambase.rotation.x * DASH_ACCEL
		move_vec += dash_vec
		print('in dash move_vec ', move_vec)
		print('in dash_vec ', dash_vec)
		air_temp_friction = DASH_FRICTION
		ground_temp_friction = DASH_FRICTION
		speed_cap = MAX_DASH_SPEED
		time_after_dash = 0.0
		dashes_left -= 1
		
	time_after_dash += delta
	
#	if air_temp_friction > AIR_FRICTION:
#		air_temp_friction *= 0.9
#	else:
#		air_temp_friction = AIR_FRICTION
#	air_temp_friction = lerp(air_temp_friction, AIR_FRICTION, 0.1)
#	if ground_temp_friction > GROUND_FRICTION:
#		ground_temp_friction *= 0.9
#	else:
#		ground_temp_friction = GROUND_FRICTION
	ground_temp_friction = lerp(ground_temp_friction, GROUND_FRICTION, 0.2)
#	if speed_cap > walk_speed_cap:
#		speed_cap *= 0.8
#	else:
#		speed_cap = walk_speed_cap
	speed_cap = lerp(speed_cap, walk_speed_cap, 0.075)
		
		
#	$MoveSpeed.text = 'move_vec\nx %+f\ny %+f\nz %+f' % [move_vec.x, move_vec.y, move_vec.z]
#	$Acceleration.text = 'accel\nx %+.3f\ny %+.3f\nz %+.3f' % [accel.x, accel.y, accel.z]
	infou.text += 'move_vec\nx %+f\ny %+f\nz %+f\n\n' % [move_vec.x, move_vec.y, move_vec.z]
	infou.text += 'accel\nx %+.3f\ny %+.3f\nz %+.3f\n\n' % [accel.x, accel.y, accel.z]
	infou.text += 'ground_temp_friction %f\nair_temp_friction %f\n\n' % [ground_temp_friction, air_temp_friction]
#	if 
	
	

	
	move_and_slide(move_vec, Vector3(0, 1, 0))

	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	
	#if Input.is_action_just_pressed("jump") and time_after_space < 
	
	if grounded:
		time_after_grounded = 0.0
		is_in_air = false
		dashes_left = dashes_max
		if not is_land_played:
#			print('is land played ', is_land_played)
#			anicam.play("LandKnock")
			play_land('LandKnock')
#			playonce('landaudio')
			landaudio.play()
			is_land_played = true
			
		if time_after_space < JUMP_BUFFER_TIME:
			jump()
			just_jumped = true
#		move_vec *= GROUND_FRICTION * delta
		move_vec *= ground_temp_friction * delta
		if time_after_dash > dash_duration:
			air_temp_friction = AIR_FRICTION
#			time_after_dash = 0.0
	else:
		time_after_grounded += delta
#		move_vec *= AIR_FRICTION * delta
		move_vec *= air_temp_friction * delta
		is_land_played = false
	
	time_after_space += delta
	
	#if grounded and Input.is_action_just_pressed("jump"):
	if Input.is_action_just_pressed("jump"):
		time_after_space = 0.0
		if (grounded or time_after_grounded < COYOTETIME) and not is_in_air:
			jump()
			just_jumped = true
			if time_after_dash < dash_jump_boost_window:
				speed_cap *= dash_jump_boost_k
				move_vec *= dash_jump_boost_k
	
	if Input.is_action_just_released("jump"):
		time_after_space_release = 0.0
		is_jump_canceled = false
	time_after_space_release += delta
	
	if not is_jump_canceled and time_after_space_release > JUMP_CANCEL_MIN_TIME:
		y_velo += JUMP_FORCE / 2 * -1
		is_jump_canceled = true
		print('after space rls ', time_after_space_release)
		
	if grounded and y_velo <= 0:
		y_velo = -0.1
		
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
		
		

		
 
	if just_jumped:
		play_anim("jump")
	elif grounded:
#		if move_vec.x == 0 and move_vec.z == 0:
		if abs(move_vec.x) < STOP_MAG and abs(move_vec.z) < STOP_MAG:
			play_anim("idle")
		else:
			play_anim("walk")
 
func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

func play_land(name):
	if anicam.is_playing():
		anicam.stop()
	anicam.play(name)
	
func jump():
	y_velo = JUMP_FORCE
	is_in_air = true
	
#	is_jump_canceled = false
	time_after_space_release = 0.0
	
	score += 1
	$Score.text = 'Score: ' + str(score)

	

