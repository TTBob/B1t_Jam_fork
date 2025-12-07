extends CharacterBody2D

signal item_picked(type)

# ==========================
# STATS
# ==========================
@export var speed: int = 100
@export var health: int = 3          # Player health = 3
@export var dmg: int = 2             # Player damage = 2

# ==========================
# NODES
# ==========================
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_label: Label = $HealthLabel
@onready var state_label: Label = $StateLabel
@onready var hurt_zone: Area2D = $hurt_zone

# ==========================
# STATE MACHINE
# ==========================
enum States { Idle, Running, Melee_Attack, Hurt, Death }
var current_State = States.Idle
var direction: Vector2

var last_flip := 1
var flip_tween: Tween

var is_hurt := false
var hurt_cooldown: float = 0.2
var hurt_zone_offset_x := 0.0

var enemies_in_range: Array = []

# ==========================
# SAFE ZONE + INVENTORY
# ==========================
var in_safe_zone: bool = false
var inventory_open: bool = false


func _ready():
	add_to_group("player")
	process_mode = Node.PROCESS_MODE_ALWAYS
	hurt_zone_offset_x = hurt_zone.position.x
	animation_player.animation_finished.connect(_on_animation_finished)


# ==========================================================
# MAIN PROCESS
# ==========================================================
func _physics_process(delta):

	_handle_inventory_input()
	_update_labels()

	if not inventory_open:
		_state_machine()

	move_and_slide()

func _update_labels():
	health_label.text = str(health)
	state_label.text = str(current_State)


# ==========================================================
# INVENTORY SYSTEM
# ==========================================================
func _handle_inventory_input():
	if Input.is_action_just_pressed("open_inventory"):
		_open_inventory()
	elif Input.is_action_just_pressed("close_inventory"):
		_close_inventory()


func _open_inventory():
	if inventory_open:
		return

	inventory_open = true
	var ui = get_tree().get_first_node_in_group("inventory_ui")
	if ui:
		ui.visible = true
		ui.update_inventory_ui()

	if not in_safe_zone:
		get_tree().paused = true


func _close_inventory():
	if not inventory_open:
		return

	inventory_open = false
	get_tree().paused = false

	var ui = get_tree().get_first_node_in_group("inventory_ui")
	if ui:
		ui.visible = false



# ==========================================================
# STATE MACHINE
# ==========================================================
func _state_machine():
	# IMPORTANT: reset velocity every frame
	velocity = Vector2.ZERO

	if Input.is_action_just_pressed("attack"):
		start_attack()

	match current_State:
		States.Idle:
			_idle_state()
		States.Running:
			_running_state()
		States.Melee_Attack:
			_attack_state()
		States.Hurt:
			_hurt_state()
		States.Death:
			_death_state()


# ==========================================================
# IDLE
# ==========================================================
func _idle_state():
	_play_anim("idle")

	direction = Input.get_vector("left","right","up","down")

	if direction != Vector2.ZERO:
		current_State = States.Running

	_handle_flip(direction.x)


# ==========================================================
# RUNNING
# ==========================================================
func _running_state():
	_movement()
	_play_anim("walk")

	if direction == Vector2.ZERO:
		current_State = States.Idle


func _movement():
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	_handle_flip(direction.x)


# ==========================================================
# ATTACK
# ==========================================================
func start_attack():
	if current_State == States.Hurt or current_State == States.Death:
		return
	current_State = States.Melee_Attack


func _attack_state():
	# No movement here; velocity already zeroed in _state_machine()
	_play_anim("attack")

	for enemy in enemies_in_range:
		if enemy and enemy.has_method("take_damage"):
			enemy.take_damage(dmg)


func _on_animation_finished(anim_name):
	if anim_name == "attack" and current_State == States.Melee_Attack:
		current_State = States.Idle


# ==========================================================
# HURT
# ==========================================================
func _hurt_state():
	_play_anim("hurt")


func take_damage(amount: int, from: Node2D = null):
	if is_hurt or current_State == States.Death:
		return

	health -= amount
	is_hurt = true
	current_State = States.Hurt

	var t = create_tween()
	t.tween_property(sprite_2d, "modulate", Color.RED, 0.1)
	t.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)

	await get_tree().create_timer(hurt_cooldown).timeout
	is_hurt = false

	if health <= 0:
		health = 1  # Prevent death for testing
		current_State = States.Idle
	else:
		current_State = States.Idle


# ==========================================================
# DEATH
# ==========================================================
func _death_state():
	_play_anim("death")
	velocity = Vector2.ZERO


# ==========================================================
# FLIP
# ==========================================================
func _handle_flip(x):
	if x == 0:
		return

	var dir = -1 if x < 0 else 1
	if last_flip == dir:
		return

	last_flip = dir

	# Flip sprite without scale issues
	sprite_2d.flip_h = (dir == -1)

	# Little bounce on flip (optional)
	if flip_tween:
		flip_tween.kill()

	flip_tween = create_tween()
	flip_tween.tween_property(sprite_2d, "scale", Vector2(1.1, 1.0), 0.05)
	flip_tween.tween_property(sprite_2d, "scale", Vector2(1.0, 1.0), 0.05)

	hurt_zone.position.x = hurt_zone_offset_x * dir


# ==========================================================
# ANIMATION HELPER
# ==========================================================
func _play_anim(name):
	if animation_player.current_animation != name:
		animation_player.play(name)


# ==========================================================
# PICKUP SIGNALS
# ==========================================================
func pickup_blood():
	emit_signal("item_picked", "blood")

func pickup_bone():
	emit_signal("item_picked", "bone")


# ==========================================================
# HURT ZONE SIGNALS
# ==========================================================
func _on_hurt_zone_body_entered(body):
	if body.is_in_group("enemy") and not enemies_in_range.has(body):
		enemies_in_range.append(body)

func _on_hurt_zone_body_exited(body):
	if enemies_in_range.has(body):
		enemies_in_range.erase(body)
