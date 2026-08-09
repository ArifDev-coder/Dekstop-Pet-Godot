extends Node2D

# Define the State of mode the Sprite
enum State {
	WALKING,
	CHILLING,
	DRAGGING,
	THROWN
}

var state: State = State.WALKING

var move_speed = 1
var direction = Vector2(1, 0) # Move Right
var is_chilling = false

var texture
var image

@onready var area = $Area2D
@onready var anim = $AnimatedSprite2D
@onready var soundfx = $Hi

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Get access to the actual OS Window
	var window = get_window()
	
	texture = anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	image = texture.get_image()

	#Transparent Setup
	get_viewport().transparent_bg = true
	window.transparent = true

	# Window Shape
	window.borderless = true

	# Keep above yout web browser
	window.always_on_top = true

	# Force to can't resize
	window.unresizable = false

	# Find the floor / taskbar
	# Get the safe area of the screen (minus taskbar)
	var usable_rect = DisplayServer.screen_get_usable_rect()

	# Calculate the floor position
	# end.y is pixel coordinate the taskbar start.
	# subtract window height to make slime on the line, no under.
	var target_y = usable_rect.end.y - window.size.y

	# Move the slime there
	# 	x = 0 (left edge), y = target_y (The taskbar/floor)
	window.position = Vector2i(0, target_y)

	# This Code not working on linux wayland
	# Run once at start
	# _update_mouse_mask()
	#Update every time animation changes
	# $AnimatedSprite2D.frame_changed.connect(_update_mouse_mask)

	area.input_event.connect(_on_area_input)

	anim.play("walk")


func _process(delta):
	# If are chilling, we hit 'return'
	# if is_chilling: return

	match state:
		State.WALKING:
			_process_walking()
		State.CHILLING:
			pass
		State.DRAGGING:
			# _process_dragging() 
			pass
		State.THROWN:
			# _process_thrown()
			pass

	_process_walking()


func _process_walking():
	# Get the window
	var window = get_window()

	# Vector2i used interger with Vector2 for the monitor pixel
	# Calculate the move
	var move_vector = Vector2i(direction * move_speed)

	# Apply to Os Window
	window.position += move_vector

	# Safe Zone
	# screen_get_usable_rect() return the screen Minus the taskbar/dock
	var usable_rect = DisplayServer.screen_get_usable_rect()

	# Check right and left edge
	if window.position.x + window.size.x > usable_rect.end.x:
		direction.x = -1 # Reverse direction
		anim.flip_h = true # flip visual
	elif window.position.x < usable_rect.position.x:
		direction.x = 1
		anim.flip_h = false

# Inputhandling for clicking the sprite
func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_chilling()
			soundfx.play()
			_start_dragging()
		else:
			pass


func _start_dragging():
	if state == State.CHILLING:
		return
	
	var window = get_window()
	var mouse_pos = DisplayServer.mouse_get_button_state()

	print("Is Dragging")


# This function not working on linux wayland
func _update_mouse_mask():
	# Get the raw image data of the Current frame
	anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	texture.get_image()

	# Manually flip the sprite while the image visual uncorrect.
	if anim.flip_h:
		image.flip_x()

	# Create the Bitmap (The Map of solid pixels)
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image, 0.1)

	# Create the Polygon
	# 0.1 = ignore fully transparent pixels
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, texture.get_size()))

	# Apply to the OS Window
	if polygons.size() > 0:
		DisplayServer.window_set_mouse_passthrough(polygons[0])

func start_chilling():
	state = State.CHILLING
	$AnimatedSprite2D.play("idle")

	await get_tree().create_timer(1.0).timeout

	state = State.WALKING
	$AnimatedSprite2D.play("walk")
