extends KinematicBody2D

class_name Player

const Ghost = preload("res://objects/PlayerGhost.tscn")

onready var sprite : Sprite = $Sprite
onready var sprite_punch : Sprite = $Sprite_Punch
onready var raycast_punch : RayCast2D = $RayCast2D_Punch
onready var audio_jump : AudioStreamPlayer2D = $Audio_Jump
onready var audio_double_jump : AudioStreamPlayer2D = $Audio_DoubleJump
onready var audio_dash : AudioStreamPlayer2D = $Audio_Dash
onready var audio_land : AudioStreamPlayer2D = $Audio_Land
onready var audio_hit : AudioStreamPlayer2D = $Audio_Hit
onready var audio_punch : AudioStreamPlayer2D = $Audio_Punch
onready var audio_brick_destroy : AudioStreamPlayer2D = $Audio_BrickDestroy
onready var tween : Tween = $Tween

const MOVE_ACCEL : float = 768.0
const MOVE_DEACCEL : float = 256.0
const MAX_MOVE_SPEED : float = 96.0
const FALL_ACCEL : float = 512.0
const MAX_FALL_SPEED : float = 256.0
const JUMP_SPEED : float = 256.0
const JUMP_CUT_SPEED : float = 32.0
const DASH_TIME : float = 0.25
const DASH_SPEED : float = 360.0
const PUNCH_TIME : float = 0.1
const PUNCH_SPEED : float = 240.0
const PUNCH_COOLDOWN : float = 0.1
const COYOTE_TIME : float = 0.25
const GHOST_TIME : float = 0.25
const RUN_ANIM_SPEED : float = 6.0

enum State {NORMAL, JUMPING, FALLING, DASHING, PUNCHING, DEAD}

var unlocked_dash : bool
var unlocked_double_jump : bool
var unlocked_punch : bool

var moving_speed : float = 0.0
var falling_speed : float = 0.0
var gravity_direction : Vector2
var target_rotation : float
var dash_amount : float
var punch_amount : float
var punch_refresh : float
var coyote_amount : float # Length of time we can still jump after having fallen from somewhere
var ghost_amount : float

var which_frame : Vector2 = Vector2.ZERO
var anim_index : float = 0.0

var state : int = State.NORMAL
var extra_jumps : int = 0
var can_dash : bool = true

var planet : StaticBody2D

func wobble_jump() -> void:
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(1.5, 0.5), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(sprite, "scale", Vector2(1.5, 0.5), Vector2.ONE, 0.2, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.1)
	tween.start()

func wobble_land() -> void:
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(0.75, 1.5), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(sprite, "scale", Vector2(0.75, 1.5), Vector2.ONE, 0.2, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.1)
	tween.start()

func wobble_turn() -> void:
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(1.0, 0.5), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(sprite, "scale", Vector2(1.0, 0.5), Vector2.ONE, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.1)
	tween.start()

func wobble_dash() -> void:
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(0.5, 2.0), 0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(sprite, "scale", Vector2(0.5, 2.0), Vector2.ONE, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.05)
	tween.start()

func make_ghost() -> void:
	var ghost : Node2D = Ghost.instance()
	ghost.global_position = sprite.global_position
	ghost.rotation = rotation
	ghost.scale = sprite.scale
	ghost.region_rect = sprite.region_rect
	get_parent().add_child(ghost)

func move_falling(velocity : Vector2, delta : float) -> void:
	var collision : KinematicCollision2D = move_and_collide(velocity * delta)
	if collision != null:
		position += collision.travel
		# Check if we've hit the floor (yes, this actually works!)
		if (collision.normal + gravity_direction).length() < PI / 4.0:
			land()
			target_rotation = collision.normal.angle() + PI
		# Alternatively, is this the ceiling?
		elif (collision.normal - gravity_direction).length() < PI / 4.0:
			falling_speed = 0.0

func move_and_check_for_wall(velocity : Vector2, delta : float) -> bool:
	var collision : KinematicCollision2D = move_and_collide(velocity * delta)
	if collision != null:
		position += collision.travel
		# Are we snuggling up against a wall?
		var relative_collision_angle : float = wrapf(collision.normal.rotated(-gravity_direction.angle()).angle() + (PI/2.0), 0.0, PI)
		if relative_collision_angle > PI*0.75: # Please don't ask me to explain this.
			return true
	return false

# Test if there's at least a given distance between us and terra firma (or terra floata, as the case may be)
func on_ground(margin : float) -> bool:
	return test_move(transform, gravity_direction * margin)

func can_dash() -> bool:
	return can_dash and unlocked_dash

func can_punch() -> bool:
	return unlocked_punch and punch_refresh <= 0.0

func movement_stuff(delta : float) -> bool:
	if Input.is_action_pressed("move_left"):
		moving_speed = clamp(moving_speed - (MOVE_ACCEL * delta), -MAX_MOVE_SPEED, MAX_MOVE_SPEED)
		if sprite.flip_v == false:
			wobble_turn()
		sprite.flip_v = true
		sprite_punch.flip_h = true
		sprite_punch.position.y = 12
		raycast_punch.cast_to.y = 8
		anim_index += RUN_ANIM_SPEED * delta
	elif Input.is_action_pressed("move_right"):
		moving_speed = clamp(moving_speed + (MOVE_ACCEL * delta), -MAX_MOVE_SPEED, MAX_MOVE_SPEED)
		if sprite.flip_v == true:
			wobble_turn()
		sprite.flip_v = false
		sprite_punch.flip_h = false
		sprite_punch.position.y = -12
		raycast_punch.cast_to.y = -8
		anim_index += RUN_ANIM_SPEED * delta
	else:
		anim_index = 0.0
		moving_speed = move_toward(moving_speed, 0.0, MOVE_DEACCEL * delta)
	# Don't bother moving if we're not... y'know, moving
	if abs(moving_speed) > 0.0:
		var moving_velocity : Vector2 = gravity_direction.rotated(-PI/2.0) * moving_speed
		return move_and_check_for_wall(moving_velocity, delta)
	else:
		return false

func falling_stuff(delta : float) -> void:
	falling_speed += FALL_ACCEL * delta
	falling_speed = clamp(falling_speed, -MAX_FALL_SPEED, MAX_FALL_SPEED)
	var falling_velocity : Vector2 = gravity_direction * falling_speed
	move_falling(falling_velocity, delta)

func jump() -> void:
	falling_speed = -JUMP_SPEED
	state = State.JUMPING
	wobble_jump()
	if unlocked_double_jump and extra_jumps == 0:
		audio_double_jump.play()
	else:
		audio_jump.play()

func fall(give_coyote : bool) -> void:
	state = State.FALLING
	if give_coyote:
		coyote_amount = COYOTE_TIME
	else:
		coyote_amount = 0.0

func land() -> void:
	if falling_speed > 64.0:
		wobble_land()
		audio_land.play()
	falling_speed = 0.0
	state = State.NORMAL
	extra_jumps = 1 if unlocked_double_jump else 0
	can_dash = true

func dash() -> void:
	state = State.DASHING
	can_dash = false
	dash_amount = DASH_TIME
	ghost_amount = GHOST_TIME
	falling_speed = 0.0
	wobble_dash()
	audio_dash.play()

func punch() -> void:
	state = State.PUNCHING
	punch_amount = PUNCH_TIME
	falling_speed = 0.0
	wobble_dash()
	sprite_punch.offset = Vector2.ZERO
	sprite_punch.show()
	audio_punch.play()
	tween.interpolate_property(sprite_punch, "offset", Vector2.ZERO, Vector2(8, 0) * -sign(sprite_punch.position.y), PUNCH_TIME)
	tween.start()

func state_normal(delta : float) -> void:
	# Let's just make sure we're actually on the ground
	movement_stuff(delta)
	falling_stuff(delta)
	if Input.is_action_just_pressed("jump"):
		jump()
	elif not on_ground(0.5):
		fall(true)
	elif Input.is_action_just_pressed("dash") and can_dash():
		dash()
	elif Input.is_action_just_pressed("punch") and can_punch():
		punch()
	# Look pretty!
	if abs(moving_speed) > 32.0:
		var running_frame : int = wrapf(anim_index, 0.0, 4.0)
		which_frame = Vector2(1 + running_frame, 1)
	else:
		which_frame = Vector2(0, 0)

func state_jumping(delta : float) -> void:
	which_frame = Vector2(2, 2)
	movement_stuff(delta)
	falling_stuff(delta)
	if falling_speed > 0.0:
		fall(false)
	elif not Input.is_action_pressed("jump"):
		falling_speed = clamp(falling_speed, -JUMP_CUT_SPEED, MAX_FALL_SPEED)
		fall(false)
	if Input.is_action_just_pressed("dash") and can_dash():
		dash()
	elif Input.is_action_just_pressed("punch") and can_punch():
		punch()

func state_falling(delta : float) -> void:
	# To avoid glitchy behaviour when standing on uneven ground
	if not on_ground(8.0):
		which_frame = Vector2(3, 2)
	movement_stuff(delta)
	coyote_amount = clamp(coyote_amount - delta, 0.0, COYOTE_TIME)
	if Input.is_action_just_pressed("jump"):
		if coyote_amount > 0.0 or on_ground(4.0):
			jump()
		elif extra_jumps > 0:
			extra_jumps -= 1
			jump()
			ghost_amount = GHOST_TIME
	falling_stuff(delta)
	if Input.is_action_just_pressed("dash") and can_dash():
		dash()
	elif Input.is_action_just_pressed("punch") and can_punch():
		punch()

func state_dashing(delta : float) -> void:
	var dashing_direction : float = -1.0 if sprite.flip_v else 1.0
	var dashing_velocity : Vector2 = gravity_direction.rotated(-PI/2.0) * DASH_SPEED * dashing_direction
	move_and_check_for_wall(dashing_velocity, delta)
	# All good dashings
	dash_amount -= delta
	if dash_amount <= 0.0:
		fall(false)

func state_punching(delta : float) -> void:
	var punching_direction : float = -1.0 if sprite.flip_v else 1.0
	var punching_velocity : Vector2 = gravity_direction.rotated(-PI/2.0) * PUNCH_SPEED * punching_direction
	move_and_check_for_wall(punching_velocity, delta)
	# Hit bricks, break bricks
	if raycast_punch.is_colliding():
		var collider : Node2D = raycast_punch.get_collider()
		if collider.is_in_group("brick"):
			collider.destroy()
			audio_brick_destroy.play()
	# All good punchings
	punch_amount -= delta
	if punch_amount <= 0.0:
		punch_refresh = PUNCH_COOLDOWN
		sprite_punch.hide()
		fall(false)

func hit() -> void:
	state = State.DEAD
	which_frame = Vector2(1, 3)
	tween.stop_all()
	tween.interpolate_property(sprite, "modulate", sprite.modulate, Color("a13d3b"), 0.1)
	tween.start()
	if not audio_hit.playing:
		audio_hit.play()
	get_tree().call_group("game", "player_hit")

func is_touching_deadly() -> bool:
	for deadly in get_tree().get_nodes_in_group("deadly"):
		if deadly.get_overlapping_bodies().has(self):
			return true
	return false

func use_interactable() -> void:
	for interactable in get_tree().get_nodes_in_group("interactable"):
		if interactable.get_overlapping_bodies().has(self):
			interactable.interact()

func check_for_interactables() -> void:
	for interactable in get_tree().get_nodes_in_group("interactable"):
		if interactable.get_overlapping_bodies().has(self):
			var message : String = interactable.get_interact_message()
			get_tree().call_group("game", "show_prompt_message", message)

func _physics_process(delta : float) -> void:
	gravity_direction = position.direction_to(planet.position)
	target_rotation = gravity_direction.angle()
	# State-specific stuff
	match state:
		State.NORMAL:
			state_normal(delta)
		State.JUMPING:
			state_jumping(delta)
		State.FALLING:
			state_falling(delta)
		State.DASHING:
			state_dashing(delta)
		State.PUNCHING:
			state_punching(delta)
	# Falling stuff
	rotation = lerp_angle(rotation, target_rotation, delta * 10.0)
	# Ghost stuff
	if ghost_amount > 0.0:
		ghost_amount -= delta
		make_ghost()
	# Punch stuff
	if punch_refresh > 0.0:
		punch_refresh -= delta
	# Ouch
	if is_touching_deadly():
		hit()
	if state != State.DEAD:
		# Check for interactable prompts
		check_for_interactables()
		if Input.is_action_just_pressed("interact"):
			use_interactable()
	# Finally, update the sprite
	sprite.region_rect.position = which_frame * Vector2(16, 16)

# Hit of a hack, but to avoid an extraneous land sound whenever we enter a new area,
# the land sound is actually muted for the first half a second.
func _on_Timer_MuteLand_timeout():
	audio_land.volume_db = 0.0
