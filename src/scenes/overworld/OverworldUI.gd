extends CanvasLayer

@onready var tooltip_label = $TooltipPanel/Label
@onready var tooltip_panel = $TooltipPanel
@onready var party_panel = $PartyPanel
@onready var party_label = $PartyPanel/Label
@onready var time_label = $TimePanel/TimeLabel
@onready var pause_menu = $PauseMenu

func _ready():
	add_to_group("overworld_ui")
	tooltip_panel.visible = false
	party_panel.visible = false
	pause_menu.visible = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			toggle_party_menu()
		elif event.is_action("ui_cancel"): # Default ESC
			toggle_pause_menu()

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
