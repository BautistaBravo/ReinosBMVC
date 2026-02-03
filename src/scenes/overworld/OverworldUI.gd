extends CanvasLayer

@onready var tooltip_label = $TooltipPanel/Label
@onready var tooltip_panel = $TooltipPanel
@onready var party_panel = $PartyPanel
@onready var party_label = $PartyPanel/Label
@onready var time_label = $TimePanel/TimeLabel
@onready var pause_menu = $PauseMenu

var inventory_panel: Panel
var inventory_grid: GridContainer

func _ready():
	add_to_group("overworld_ui")
	tooltip_panel.visible = false
	party_panel.visible = false
	pause_menu.visible = false
	setup_inventory_ui()

func setup_inventory_ui():
	inventory_panel = Panel.new()
	inventory_panel.name = "InventoryPanel"
	inventory_panel.visible = false
	inventory_panel.size = Vector2(400, 300)
	inventory_panel.position = Vector2(300, 100)
	add_child(inventory_panel)

	var label = Label.new()
	label.text = "Inventory"
	label.position = Vector2(10, 5)
	inventory_panel.add_child(label)

	inventory_grid = GridContainer.new()
	inventory_grid.columns = 4
	inventory_grid.position = Vector2(10, 40)
	inventory_panel.add_child(inventory_grid)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			toggle_party_menu()
		elif event.keycode == KEY_I:
			toggle_inventory()
		elif event.is_action("ui_cancel"): # Default ESC
			toggle_pause_menu()

func toggle_inventory():
	inventory_panel.visible = not inventory_panel.visible
	if inventory_panel.visible:
		update_inventory_display()

func update_inventory_display():
	for child in inventory_grid.get_children():
		child.queue_free()

	for entry in InventoryManager.inventory:
		var item = entry["item"]
		var qty = entry["quantity"]

		var item_box = VBoxContainer.new()

		var icon_rect = TextureRect.new()
		if item.icon:
			icon_rect.texture = item.icon
		else:
			icon_rect.custom_minimum_size = Vector2(32, 32)

		item_box.add_child(icon_rect)

		var lbl = Label.new()
		lbl.text = "%s x%d" % [item.item_name, qty]
		item_box.add_child(lbl)

		inventory_grid.add_child(item_box)

func toggle_party_menu():
	party_panel.visible = not party_panel.visible
	if party_panel.visible:
		update_party_stats()

func toggle_pause_menu():
	pause_menu.visible = not pause_menu.visible

func update_party_stats():
	var text = "Party Stats:\n"
	for member in GameManager.player_party:
		text += "%s: HP %d/%d, AGI %d\n" % [member.character_name, member.current_hp, member.max_hp, member.agility]
	party_label.text = text

func show_tooltip(entity):
	tooltip_panel.visible = true
	var text = "Entity: %s\n" % entity.entity_name
	if entity.is_enemy:
		text += "Enemy Party:\n"
		for member in entity.party:
			text += "- %s (HP: %d, AGI: %d)\n" % [member.character_name, member.max_hp, member.agility]
	else:
		text += "Friendly"
	tooltip_label.text = text

func hide_tooltip():
	tooltip_panel.visible = false

func _process(delta):
	if tooltip_panel.visible:
		tooltip_panel.position = get_viewport().get_mouse_position() + Vector2(15, 15)

	update_time_ui()

func update_time_ui():
	var time_text = TimeManager.get_formatted_time()
	var day_num = TimeManager.get_day_number()
	time_label.text = "Day %d\n%s" % [day_num, time_text]
