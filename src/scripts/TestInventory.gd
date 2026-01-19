extends Node

func _ready():
	print("Starting Inventory Test...")

	# 1. Setup Data (Mocks)
	var sword = ItemData.new()
	sword.item_name = "Iron Sword"
	sword.price = 100
	sword.type = ItemData.ItemType.EQUIPMENT

	var potion = ItemData.new()
	potion.item_name = "Health Potion"
	potion.price = 20
	potion.type = ItemData.ItemType.CONSUMABLE

	var loot_table = LootTable.new()
	loot_table.items = [sword, potion]
	loot_table.probabilities = [0.5, 1.0]

	# 2. Test InventoryManager
	# Note: InventoryManager is an Autoload.
	InventoryManager.add_item(sword, 1)
	InventoryManager.add_item(potion, 5)

	if InventoryManager.has_item(sword):
		print("PASS: Has sword")
	else:
		printerr("FAIL: Missing sword")

	if InventoryManager.has_item(potion, 5):
		print("PASS: Has 5 potions")
	else:
		printerr("FAIL: Missing potions")

	InventoryManager.remove_item(potion, 2)
	if InventoryManager.has_item(potion, 3):
		print("PASS: Removed potions correctly")
	else:
		printerr("FAIL: Remove item failed")

	# 3. Test Loot Logic
	print("Rolling loot...")
	var drops = loot_table.roll_loot()
	print("Drops obtained: ", drops.size())
	for item in drops:
		print("- ", item.item_name)

	print("Test Complete.")
