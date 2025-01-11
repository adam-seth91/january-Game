extends CharacterBody2D

# Enemy States
enum EnemyState { IDLE, WALK }

# Enemy Properties
@export var speed: float = 100.0  # Movement speed
@export var health: int = 3  # Starting health
@export var player_detection_range: float = 200.0  # Detection range for the player

# State Variables
var current_state: EnemyState = EnemyState.IDLE

# References to child nodes
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Node2D = null  # Will be assigned dynamically in _ready()

func _ready():
	# Find the player in the scene
	player = get_parent().get_node("Player")  # Adjust path to your Player node
	set_random_state()

func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.IDLE:
			# Wander randomly
			if randf() < 0.01:  # Occasionally switch to walk state
				set_state(EnemyState.WALK)
		EnemyState.WALK:
			# Wander in a random direction
			wander()
		
		# If player is within range, pursue them
		if player and position.distance_to(player.position) < player_detection_range:
			pursue_player()

	# Move the enemy
	move_and_slide()

	# Flip sprite based on movement direction
	if velocity.x > 0:
		anim_sprite.scale.x = 1  # Face right
	elif velocity.x < 0:
		anim_sprite.scale.x = -1  # Face left

func set_state(new_state: EnemyState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	match current_state:
		EnemyState.IDLE:
			anim_sprite.play("warlock_idle")
			velocity = Vector2.ZERO
		EnemyState.WALK:
			anim_sprite.play("warlock_walk")
			velocity.x = randf() * 2 - 1  # Random horizontal direction
			velocity = velocity.normalized() * speed

func wander() -> void:
	if randf() < 0.01:  # Occasionally stop wandering
		set_state(EnemyState.IDLE)
	else:
		# Keep moving in the current direction
		velocity.x = velocity.x

func pursue_player() -> void:
	if player:
		velocity = (player.position - position).normalized() * speed
		anim_sprite.play("warlock_walk")

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	queue_free()  # Remove the enemy from the scene
