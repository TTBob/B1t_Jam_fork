extends Resource
class_name Ingredient


@export var id: String = ""               # unique name: "milk", "bone", etc.
@export var display_name: String = ""     # shown to player
@export var description: String = ""      # optional
@export var icon: Texture2D               # inventory icon
@export var stackable: bool = true        # can stack in inventory
@export var max_stack: int = 99           # stack size limit
@export var rarity: int = 0               # 0 = common, 1 = rare
@export var is_world_item: bool = false   # true = bone/salt/oats, false = milk/blood/honey
