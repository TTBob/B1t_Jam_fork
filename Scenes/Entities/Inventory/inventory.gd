extends Control

# ====================================================================
# EXPORTS
# ====================================================================

@export var blood_count: RichTextLabel
@export var bone_count: RichTextLabel

@export var salt_name: RichTextLabel
@export var salt_amount: RichTextLabel
@export var salt_button: Button

@export var milk_name: RichTextLabel
@export var milk_amount: RichTextLabel
@export var milk_button: Button

@export var honey_name: RichTextLabel
@export var honey_amount: RichTextLabel
@export var honey_button: Button

@export var oats_name: RichTextLabel
@export var oats_amount: RichTextLabel
@export var oats_button: Button

@export var fill_duration := 0.3
@export var bounce_scale := Vector2(1.3, 1.3)
@export var bounce_duration := 0.15
@export var max_progress := 10

@export var salt_bar: TextureProgressBar
@export var milk_bar: TextureProgressBar
@export var honey_bar: TextureProgressBar
@export var oats_bar: TextureProgressBar

@onready var move_to_cooking_game: Button = $Move_to_cooking_game

# ====================================================================
# GLOBAL INVENTORY DATA
# ====================================================================

var blood_arr := GameData.blood_arr
var bone_arr := GameData.bone_arr

var completed_ingredients := GameData.completed_ingredients
var progress_values := GameData.progress_values

@export var ingredient_requirements := {
	"salt": {"bones": 5, "blood": 3},
	"oats": {"bones": 7, "blood": 7},
	"milk": {"bones": 4, "blood": 10},
	"honey": {"bones": 7, "blood": 7},
}

# ====================================================================
# READY
# ====================================================================
func _ready():
	visible = false  # UI STARTS HIDDEN
	add_to_group("inventory_ui")
	_setup_ingredient_ui()
	_connect_buttons()
	_setup_progress_bars()
	update_inventory_ui()


func _process(delta):
	_handle_visibility_controls()

	# disable buttons unless inside safe zone
	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	var allow = player.in_safe_zone

	salt_button.disabled = not allow or completed_ingredients["salt"]
	milk_button.disabled = not allow or completed_ingredients["milk"]
	honey_button.disabled = not allow or completed_ingredients["honey"]
	oats_button.disabled = not allow or completed_ingredients["oats"]


# ====================================================================
# INPUT → SHOW / HIDE UI
# ====================================================================
func _handle_visibility_controls():
	# If E pressed → open
	if Input.is_action_just_pressed("open_inventory"):
		visible = true
		update_inventory_ui()

	# If Q pressed → close
	if Input.is_action_just_pressed("close_inventory"):
		visible = false


# ====================================================================
# UI SETUP
# ====================================================================

func _setup_progress_bars():
	salt_bar.max_value = max_progress
	milk_bar.max_value = max_progress
	honey_bar.max_value = max_progress
	oats_bar.max_value = max_progress


func _setup_ingredient_ui():
	_set_text("salt", salt_amount)
	_set_text("milk", milk_amount)
	_set_text("honey", honey_amount)
	_set_text("oats", oats_amount)


func _set_text(key, label):
	if completed_ingredients[key]:
		label.text = ""
	else:
		var r = ingredient_requirements[key]
		label.text = "Needs %s Bones + %s Blood Drops" % [r.bones, r.blood]


# ====================================================================
# DONATION
# ====================================================================

func _connect_buttons():
	salt_button.pressed.connect(func(): _donate("salt", salt_amount, salt_button, salt_bar))
	milk_button.pressed.connect(func(): _donate("milk", milk_amount, milk_button, milk_bar))
	honey_button.pressed.connect(func(): _donate("honey", honey_amount, honey_button, honey_bar))
	oats_button.pressed.connect(func(): _donate("oats", oats_amount, oats_button, oats_bar))


func _donate(key, ui_label, button, bar):
	var player = get_tree().get_first_node_in_group("player")

	if not player.in_safe_zone:
		print("Must be inside ritual/safe zone to donate!")
		return

	var req = ingredient_requirements[key]

	if bone_arr.size() < req.bones or blood_arr.size() < req.blood:
		print("Not enough items to submit ", key)
		return

	# Deduct items
	for i in range(req.bones): bone_arr.pop_back()
	for i in range(req.blood): blood_arr.pop_back()

	progress_values[key] = max_progress
	animate_bar(bar, max_progress)
	bounce_bar(bar)

	completed_ingredients[key] = true
	ui_label.text = ""
	button.disabled = true

	update_inventory_ui()
	_check_all_completed()


# ====================================================================
# ANIMATIONS
# ====================================================================
func animate_bar(bar, value):
	var t = create_tween()
	t.tween_property(bar, "value", value, fill_duration)


func bounce_bar(bar):
	var t = create_tween()
	t.tween_property(bar, "scale", bounce_scale, bounce_duration)
	t.tween_property(bar, "scale", Vector2.ONE, bounce_duration)


# ====================================================================
# END CHECK / SCENE MOVE
# ====================================================================
func _check_all_completed():
	for k in completed_ingredients:
		if not completed_ingredients[k]:
			move_to_cooking_game.disabled = true
			return
	move_to_cooking_game.disabled = false


func update_inventory_ui():
	blood_count.text = "Blood: %s" % blood_arr.size()
	bone_count.text = "Bones: %s" % bone_arr.size()


func _on_Move_to_cooking_game_pressed():
	if move_to_cooking_game.disabled:
		print("Finish all rituals first!")
		return

	get_tree().change_scene_to_file("res://CookingGame.tscn")
