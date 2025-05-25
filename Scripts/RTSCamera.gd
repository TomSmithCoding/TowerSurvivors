extends Node3D

# Cam move
@export_range(0,100,1) var camera_move_speed:float = 20.0

# Cam pan
@export_range(0,32,4) var camera_auto_pan_margin:int = 16
@export_range(0,20,0.5) var camera_auto_pan_speed:float = 12
@export_range(0,100,1) var camera_xpan_min = -10.0
@export_range(0,100,1) var camera_xpan_max = 10.0
@export_range(0,100,1) var camera_zpan_max = 6
@export_range(0,100,1) var camera_zpan_min = -6

# Cam Rotate
@export_range(0,10,1) var camera_socket_rotate_x_min:float = -1.2
@export_range(0,10,1) var camera_socket_rotate_x_max:float = -0.2
@export_range(0,20,1) var camera_base_rotate_speed:float = 8
@export_range(0,10,0.1) var camera_rotate_speed:float = 0.1
var camera_rotation_direction:float = 0

# Cam zoom
var camera_zoom_direction:int = 0
@export_range(0,100,1) var camera_zoom_speed = 40.0
@export_range(0,100,1) var camera_zoom_min = 7.0
@export_range(0,100,1) var camera_zoom_max = 25.0
@export_range(0,2,0.1) var camera_zoom_speed_damp:float = 0.92

# Flags
var camera_can_process:bool = true
var camera_can_move_base:bool = true
var camera_can_move_zoom:bool = true
var camera_can_pan:bool = true
var camera_can_rotate:bool = true
var camera_can_rotate_socket_x:bool = true
var camera_can_rotate_by_mouse_offsets:bool = true

# Internal Flag
var camera_is_rotating_base:bool = false
var camera_is_rotating_mouse:bool = false
var mouse_last_position:Vector2 = Vector2.ZERO

# Nodes
@onready var camera_socket:Node3D = $CameraSocket
@onready var camera:Camera3D = $CameraSocket/Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !camera_can_process:return
	
	camera_base_move(delta)
	camera_zoom_update(delta)
	camera_auto_panning(delta)
	camera_base_rotate(delta)
	camera_rotates_to_mouse_offsets(delta)
	
func _unhandled_input(event:InputEvent) -> void:
	# Cam zoom controls
	if event.is_action("cam_zoom_in"):
		camera_zoom_direction = -1
	elif event.is_action("cam_zoom_out"):
		camera_zoom_direction = 1
	
	# Cam rotate controls
	if event.is_action_pressed("camera_rotate_right"):
		camera_rotation_direction = -1
		camera_is_rotating_base = true
	if event.is_action_pressed("camera_rotate_left"):
		camera_rotation_direction = 1
		camera_is_rotating_base = true
	elif event.is_action_released("camera_rotate_left") or event.is_action_released("camera_rotate_right"):
		camera_is_rotating_base = false
		
	if event.is_action_pressed("camera_rotate"):
		mouse_last_position = get_viewport().get_mouse_position()
		camera_is_rotating_mouse = true
	elif event.is_action_released("camera_rotate"):
		camera_is_rotating_mouse = false
		
# Moves camera base
func camera_base_move(delta:float) -> void:
	if !camera_can_move_base:return
	var velocity_direction:Vector3 = Vector3.ZERO
	
	if Input.is_action_pressed("cam_forward"): 	velocity_direction -= transform.basis.z
	if Input.is_action_pressed("cam_backward"): velocity_direction += transform.basis.z
	if Input.is_action_pressed("cam_right"): 	velocity_direction += transform.basis.x
	if Input.is_action_pressed("cam_left"): 	velocity_direction -= transform.basis.x 
	
	if(	position.x <= camera_xpan_max and 
		position.x >= camera_xpan_min and
		position.z <= camera_zpan_max and
		position.z >= camera_zpan_min	):
		position += velocity_direction.normalized() * camera_move_speed * delta
	elif(self.position.x >= camera_xpan_max):
		self.position.x = camera_xpan_max-0.3
	elif(self.position.x <= camera_xpan_min):
		self.position.x = camera_xpan_min+0.3
	elif(self.position.z >= camera_zpan_max):
		self.position.z = camera_zpan_max-0.3
	elif(self.position.z <= camera_zpan_min):
		self.position.z = camera_zpan_min+0.3
	#print("z ",position.z)
	#print("x ",position.x)

# Controls zoom of camera
func camera_zoom_update(delta:float) -> void:
	if !camera_can_move_zoom:return
	
	var new_zoom:float = clamp(camera.position.z + camera_zoom_speed * camera_zoom_direction * delta, camera_zoom_min, camera_zoom_max)
	camera.position.z = new_zoom
	camera_zoom_direction *= camera_zoom_speed_damp
	
# Rotate camera sockets based on mouse offset
func camera_rotates_to_mouse_offsets(delta: float) -> void:
	#print(camera_is_rotating_mouse)
	if !camera_can_rotate_by_mouse_offsets or !camera_is_rotating_mouse:return
	var mouse_offset:Vector2 = get_viewport().get_mouse_position()
	mouse_offset = mouse_offset - mouse_last_position
	
	mouse_last_position = get_viewport().get_mouse_position()
	
	camera_base_rotate_left_right(delta, mouse_offset.x)
	camera_socket_rotate_x(delta, mouse_offset.y)
	
# Rotate camera base
func camera_base_rotate(delta:float) -> void:
	if !camera_can_rotate or !camera_is_rotating_base:return
	
	camera_base_rotate_left_right(delta, camera_rotation_direction * camera_base_rotate_speed)
	# Rotate

# Rotates camera socket
func camera_socket_rotate_x(delta:float, dir:float) -> void:
	if !camera_can_rotate_socket_x:return
	
	var new_rotation_x:float = camera_socket.rotation.x
	new_rotation_x -= dir * delta * camera_rotate_speed
	new_rotation_x = clamp(new_rotation_x, camera_socket_rotate_x_min, camera_socket_rotate_x_max)
	camera_socket.rotation.x = new_rotation_x
	
# Rotates camera base
func camera_base_rotate_left_right(delta:float, dir:float) -> void:
	rotation.y += dir * camera_rotate_speed * delta 

# Pans the camera
func camera_auto_panning(delta:float) -> void:
	if !camera_can_pan:return
	
	var viewport_current:Viewport = get_viewport()
	var pan_direction:Vector2 = Vector2(-1, -1)
	var viewport_visible_rectange:Rect2i = Rect2i(viewport_current.get_visible_rect())
	var viewport_size:Vector2i = viewport_visible_rectange.size
	var current_mouse_position:Vector2 = viewport_current.get_mouse_position()
	var margin:float = camera_auto_pan_margin #shortcut var
	var zoom_factor:float = camera.position.z * 0.1
	# X Pan
	if( (current_mouse_position.x < margin) or (current_mouse_position.x > viewport_size.x - margin) ):
		if current_mouse_position.x > viewport_size.x/2:
			pan_direction.x = 1
		if(self.position.x <= camera_xpan_max and self.position.x >= camera_xpan_min):
			translate(Vector3(pan_direction.x * delta * camera_auto_pan_speed * zoom_factor, 0, 0))
		elif(self.position.x >= camera_xpan_max):
			self.position.x = camera_xpan_max-0.1
		elif(self.position.x <= camera_xpan_min):
			self.position.x = camera_xpan_min+0.1

	# Y Pan
	if( (current_mouse_position.y < margin) or (current_mouse_position.y > viewport_size.y- margin) ):
		if current_mouse_position.y > viewport_size.y/2:
			pan_direction.y = 1
		if(self.position.z <= camera_zpan_max and self.position.z >= camera_zpan_min):
			translate(Vector3(0, 0, pan_direction.y * delta * camera_auto_pan_speed * zoom_factor))
		elif(self.position.z >= camera_zpan_max):
			self.position.z = camera_zpan_max-0.1
		elif(self.position.z <= camera_zpan_min):
			self.position.z = camera_zpan_min+0.1
