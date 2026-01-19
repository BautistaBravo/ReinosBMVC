extends Node

# Inventory is an Array of Dictionaries: { "item": ItemData, "quantity": int }
var inventory: Array = []

func add_item(item: ItemData, quantity: int = 1):
	var found = false
	for entry in inventory:
		if entry["item"] == item:
			entry["quantity"] += quantity
			found = true
			break
	if not found:
		inventory.append({ "item": item, "quantity": quantity })
	print("Added %d of %s" % [quantity, item.item_name])

func remove_item(item: ItemData, quantity: int = 1) -> bool:
	for i in range(inventory.size()):
		if inventory[i]["item"] == item:
			if inventory[i]["quantity"] >= quantity:
				inventory[i]["quantity"] -= quantity
				if inventory[i]["quantity"] <= 0:
					inventory.remove_at(i)
				return true
	return false

func has_item(item: ItemData, quantity: int = 1) -> bool:
	for entry in inventory:
		if entry["item"] == item:
			return entry["quantity"] >= quantity
	return false

func get_save_data() -> Array:
	var data = []
	for entry in inventory:
		# Ensure the item is a saved resource with a path
		if entry["item"].resource_path != "":
			data.append({
				"path": entry["item"].resource_path,
				"quantity": entry["quantity"]
			})
	return data

func load_save_data(data: Array):
	inventory.clear()
	for entry_data in data:
		var path = entry_data.get("path", "")
		if path != "" and ResourceLoader.exists(path):
			var item = load(path) as ItemData
			if item:
				inventory.append({ "item": item, "quantity": entry_data["quantity"] })
		else:
			printerr("Failed to load item from path: " + str(path))
