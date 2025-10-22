extends CharacterBody3D

#Movement constants
const acceleration = 5 #measured in m/s
const natural_deceleration = 0.99995
const natural_roll_deceleration = 0.995
const mouse_sensitivity = 0.002
const roll_speed = 0.002


#velocity variables
var target_velocity = Vector3.ZERO
var target_roll_velocity = 0

#collision variables 
var impact
var bounces = 0
var remaining

#movement  variables
var current_cam = 1
var move_disabled = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void: #called on input events(key press, mouse movement, that type of stuff)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: #Had to get an online explanation to local rotation
		#TODO: Make this more space-like. Rather than setting motion, add rotation velocity while mouse is motion.
		rotate_object_local(Vector3.UP, -event.relative.x * mouse_sensitivity) #Yaw control
		rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity) #Pitch Control
	
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			quit_menu()
		
		elif event.keycode == KEY_1 and Input.is_key_pressed(KEY_V):
			$MainCam.make_current()
		elif event.keycode == KEY_2 and Input.is_key_pressed(KEY_V):
			$SecondaryCam.make_current()

func quit_menu() -> void: # TODO: Make proper menu in future!!!
	get_tree().quit()

func update_rotation_feed() -> void: #updates debug readouts
	var rotX = snapped(rotation_degrees.x, 0.01)
	var rotY = snapped(rotation_degrees.y, 0.01)
	var rotZ = snapped(rotation_degrees.z, 0.01)
	$MainCam/DebugInfo/Rotation.text = "RotX:"+str(rotX)+" RotY:"+str(rotY)+" RotZ:"+str(rotZ)
	$SecondaryCam/DebugInfo/Rotation.text = "RotX:"+str(rotX)+" RotY:"+str(rotY)+" RotZ:"+str(rotZ)

func update_position_feed() -> void:#updates debug readouts
	var posX = snapped(position.x, 0.1)
	var posY = snapped(position.y, 0.1)
	var posZ = snapped(position.z, 0.1)
	$MainCam/DebugInfo/Position.text = "PosX:"+str(posX)+" PosY:"+str(posY)+" PosZ:"+str(posZ)
	$SecondaryCam/DebugInfo/Position.text = "PosX:"+str(posX)+" PosY:"+str(posY)+" PosZ:"+str(posZ)

func update_velocity_feed() -> void:#updates debug readouts
	var velX = snapped(velocity.x,0.1)
	var velY = snapped(velocity.y,0.1)
	var velZ = snapped(velocity.z,0.1)
	$MainCam/DebugInfo/Velocity.text = "VelX:"+str(velX)+" VelY:"+str(velY)+" VelZ:"+str(velZ)
	$SecondaryCam/DebugInfo/Velocity.text = "VelX:"+str(velX)+" VelY:"+str(velY)+" VelZ:"+str(velZ)


func _physics_process(delta: float) -> void: #Runs on pyhsics processing ticks, not the same as rendering
	if Flags.debug_mode == true:#Debug mode setup
		$MainCam/DebugInfo.visible = true
		$SecondaryCam/DebugInfo.visible = true
		
		update_rotation_feed()
		update_position_feed()
		update_velocity_feed()
	
	
	#Roll control
	#Done in pyhsics to prevent repeating keypress delay
	var actual_roll_distance = 0
	if Input.is_key_pressed(KEY_Q):
		target_roll_velocity += roll_speed
	if Input.is_key_pressed(KEY_E):
		target_roll_velocity += -roll_speed
	target_roll_velocity *= natural_roll_deceleration #Natural deceleration
	
	actual_roll_distance = target_roll_velocity
	rotate_object_local(Vector3.FORWARD,actual_roll_distance)
	
	
	#Momentum-based spaceflight time
	var target_acceleration = Vector3.ZERO
	var relative_acceleration = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		target_acceleration.z += (-acceleration*delta) #Applying axial acceleration, compensated for time since last tick
	if Input.is_key_pressed(KEY_S):
		target_acceleration.z += (acceleration*delta)#Applying axial acceleration, compensated for time since last tick
	if Input.is_key_pressed(KEY_A):
		target_acceleration.x += (-acceleration*delta)#Applying axial acceleration, compensated for time since last tick
	if Input.is_key_pressed(KEY_D):
		target_acceleration.x += (acceleration*delta)#Applying axial acceleration, compensated for time since last tick
	if Input.is_key_pressed(KEY_CTRL):
		target_acceleration.y += (-acceleration*delta)#Applying axial acceleration, compensated for time since last tick
	if Input.is_key_pressed(KEY_SPACE):
		target_acceleration.y += (acceleration*delta)#Applying axial acceleration, compensated for time since last tick
	
	relative_acceleration = transform.basis * target_acceleration #Rotate movement to be relative to ship's orientation
	target_velocity += relative_acceleration #Apply acceleration
	
	target_velocity *= natural_deceleration #Natural deceleration
	
	velocity = target_velocity
	velocity += get_gravity() * delta #Apply gravity

	
	impact = move_and_collide(velocity*delta) #Built in function to have nice movement, velocity, and collision
	
	if impact != null:
		var collider = impact.get_collider()
		var bounce = collider.physics_material_override.bounce
		
		var impact_normal = impact.get_normal()
		#impact_normal *= bounce
		#impact_normal = impact_normal.normalized()
				
		velocity = velocity.bounce(impact_normal)
		velocity *= bounce
		target_velocity = velocity
		
		impact = null
		impact = move_and_collide(velocity*delta)
