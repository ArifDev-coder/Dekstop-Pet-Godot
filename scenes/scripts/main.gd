extends Node2D

var move_speed = 2
var direction = Vector2(1, 0) # Move Right

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Get access to the actual OS Window
	var window = get_window()

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
	# 1. Get the safe area of the screen (minus taskbar)
	var usable_rect = DisplayServer.screen_get_usable_rect()

	# 2. Calculate the floor position
	# end.y is pixel coordinate the taskbar start.
	# subtract window height to make slime on the line, no under.
	var target_y = usable_rect.end.y - window.size.y

	# 3. Move the slime there
	# 	x = 0 (left edge), y = target_y (The taskbar/floor)
	window.position = Vector2i(0, target_y)

func _process(delta):
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
		$AnimatedSprite2D.flip_h = true # flip visual
	elif window.position.x < usable_rect.position.x:
		direction.x = 1
		$AnimatedSprite2D.flip_h = false