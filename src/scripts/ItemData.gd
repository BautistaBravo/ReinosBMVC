extends Resource
class_name ItemData

@export var item_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var price: int = 0
enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM, MATERIAL }
@export var type: ItemType = ItemType.CONSUMABLE
