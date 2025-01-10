extends CharacterBody2D

# Enums for state management
enum PlayerState { IDLE, RUN, JUMP }

# Player properties
@export var speed: float = 200.0  # Horizontal movement speed
@export var jump_force: float = -200.0  # Upward jump force
@export var gravity: float = 800.0  # Gravity applied to the player

# State variables
var current_state: PlayerState = PlayerState.IDLE
var input_direction: Vector2 = Vector2.ZERO

# References to child nodes
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Physics process is better for movement and physics updates
func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += gravity * delta

	# Handle horizontal movement inputs
	input_direction.x = 0
	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("left"):
		input_direction.x -= 1

	# Apply movement
	velocity.x = input_direction.x * speed

	# Flip the sprite based on movement direction
	if input_direction.x > 0:  # Moving right
		anim_sprite.scale.x = 1  # Default scale
	elif input_direction.x < 0:  # Moving left
		anim_sprite.scale.x = -1  # Flip horizontally

	# Handle jump input
	if is_on_floor and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
		set_state(PlayerState.JUMP)

	# Determine state and play the correct animation
	if velocity.y < 0:  # Jumping upwards
		set_state(PlayerState.JUMP)
	elif is_on_floor:
		if input_direction.x == 0:  # Not moving
			set_state(PlayerState.IDLE)
		else:  # Moving left or right
			set_state(PlayerState.RUN)

	# Move the player
	move_and_slide()

# Function to handle state transitions and animations
func set_state(new_state: PlayerState) -> void:
	# Avoid redundant state transitions
	if current_state == new_state:
		return

	# Update the current state
	current_state = new_state

	# Play the corresponding animation
	match current_state:
		PlayerState.IDLE:
			anim_sprite.play("idle")
		PlayerState.RUN:
			anim_sprite.play("run")
		PlayerState.JUMP:
			anim_sprite.play("jump")  # Replace with your actual jump animation
