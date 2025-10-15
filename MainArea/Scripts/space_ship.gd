extends CharacterBody3D

const acceleration = 10 #measured in m/s
const boost_acceleration = 15 #measured in m/s
const mouse_sensitivity = 0.002
const roll_speed = 0.1


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: #Had to get an online explanation to local rotation
		rotate_object_local(Vector3.UP, -event.relative.x * mouse_sensitivity) #Yaw control
		rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity) #Pitch Control
	
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			quit_menu()


func quit_menu() -> void: # TODO: Make proper menu in future!!!
	get_tree().quit()

func update_rotation_feed() -> void:
	var rotX = snapped(rotation_degrees.x, 0.01)
	var rotY = snapped(rotation_degrees.y, 0.01)
	var rotZ = snapped(rotation_degrees.z, 0.01)
	$Camera3D/DebugInfo/Rotation.text = "RotX:"+str(rotX)+"RotY:"+str(rotY)+"RotZ:"+str(rotZ)

func update_position_feed() -> void:
	var posX = snapped(position.x, 0.1)
	var posY = snapped(position.y, 0.1)
	var posZ = snapped(position.z, 0.1)
	$Camera3D/DebugInfo/Position.text = "PosX:"+str(posX)+"PosY:"+str(posY)+"PosZ:"+str(posZ)


func _physics_process(delta: float) -> void: #Runs on pyhsics processing ticks, not the same as rendering
	if Flags.debug_mode == true:
		update_rotation_feed()
		update_position_feed()
	
	#Roll control
	var target_roll_velocity = 0
	if Input.is_key_pressed(KEY_Q):#Done this way to prevent repeating keypress delay
		target_roll_velocity += roll_speed
	if Input.is_key_pressed(KEY_E):
		target_roll_velocity += -roll_speed
	rotate_object_local(Vector3.FORWARD,target_roll_velocity)
	
	
