# Codebase Documentation

This document provides a reference for all functions in the codebase, organized by file.

## src/autoload/TimeManager.gd

Manages the in-game time cycle (day/night) and time scaling.

* **`_process(delta)`**
  Updates the accumulated game time based on the delta and current time scale. Triggers `day_started` and `night_started` signals when the cycle phase changes.

* **`set_time_scale(scale: float)`**
  Sets the speed at which game time passes. `1.0` is normal speed.

* **`get_game_time_hours() -> float`**
  Calculates and returns the current in-game time in hours (0.0 to 24.0), accounting for the different durations of day and night phases.

* **`get_day_number() -> int`**
  Returns the current day number, starting from 1.

* **`get_formatted_time() -> String`**
  Returns the current in-game time formatted as a string "HH:MM".

* **`get_save_data() -> Dictionary`**
  Returns a dictionary containing the current time state (accumulated seconds and day/night flag) for saving.

* **`load_save_data(data: Dictionary)`**
  Restores the time state from a provided dictionary.

## src/autoload/GameManager.gd

Central manager for game state, including party management, scene transitions, and save/load functionality.

* **`_ready()`**
  Called when the node enters the scene tree. Currently empty.

* **`start_new_game()`**
  Initializes a new game session. Resets the player party with default characters, resets time scale, and changes the scene to the Overworld.

* **`start_combat(enemy_party: Array)`**
  Transitions the game to the Combat scene. Sets the current enemy party and slows down time.

* **`return_to_overworld()`**
  Transitions the game back to the Overworld scene. Clears the enemy party and restores normal time scale.

* **`save_game()`**
  Serializes the current game state (map, time, party) to `user://savegame.json`.

* **`load_game()`**
  Loads the game state from `user://savegame.json`. If no save exists, starts a new game.

* **`apply_save_data(data: Dictionary)`**
  Parses a save data dictionary and restores the game state (map, time, party members).

## src/scripts/CharacterData.gd

A resource class (Data Model) representing a character's stats and state.

* **`_init(p_name, p_hp, p_agi, p_atk, p_def, p_is_enemy, p_race, p_level, p_xp)`**
  Constructor to initialize character attributes. Default values are provided.

* **`add_experience(amount: int)`**
  Adds experience points to the character and triggers level-ups if the threshold is met.

* **`get_xp_for_next_level() -> int`**
  Calculates the XP required for the next level based on the character's race and current level.

* **`_level_up()`**
  Increments the character's level, increases stats by a percentage, and fully heals the character. Emits `leveled_up` signal.

* **`to_dictionary() -> Dictionary`**
  Serializes the character's data into a dictionary.

* **`from_dictionary(data: Dictionary) -> CharacterData`**
  Static method that creates a new `CharacterData` instance from a dictionary.

## src/scenes/main_menu/MainMenu.gd

Script for the Main Menu UI.

* **`_on_new_game_pressed()`**
  Callback for the "New Game" button. Calls `GameManager.start_new_game()`.

* **`_on_load_game_pressed()`**
  Callback for the "Load Game" button. Calls `GameManager.load_game()`.

## src/scenes/entities/BaseEntity.gd

Script for interactive entities in the world (e.g., NPCs, enemies).

* **`_ready()`**
  Initializes the entity, enables input picking, connects mouse signals, and creates a mock party (if needed).

* **`_on_mouse_entered()`**
  Callback when mouse hovers over the entity. Signals the UI to show a tooltip.

* **`_on_mouse_exited()`**
  Callback when mouse leaves the entity. Signals the UI to hide the tooltip.

* **`interact()`**
  Called when the player interacts with the entity. Starts combat if the entity is an enemy, otherwise prints a greeting.

## src/scenes/ui/PauseMenu.gd

Script for the in-game Pause Menu.

* **`_on_resume_pressed()`**
  Hides the pause menu.

* **`_on_save_pressed()`**
  Triggers the game save via `GameManager.save_game()`.

* **`_on_quit_pressed()`**
  Quits the current session and returns to the Main Menu.

## src/scenes/combat/Combat.gd

Manages the combat flow, turns, and actions.

* **`_ready()`**
  Initializes the combat scene by spawning player and enemy parties.

* **`spawn_party(party, start_pos, is_player)`**
  Instantiates `Combatant` scenes for each member of a party and positions them on screen.

* **`_process(delta)`**
  Main loop for combat. Updates ATB for combatants and checks if any are ready to act.

* **`start_turn_phase()`**
  Initiates the turn selection phase, determining which character acts next.

* **`update_active_combatant()`**
  Updates the UI and state for the currently active combatant. Triggers enemy AI or waits for player input.

* **`_input(event)`**
  Handles player input during their turn (selecting actions via keys).

* **`perform_enemy_turn(enemy)`**
  AI logic for enemies. Selects a random target and attacks.

* **`perform_attack(attacker)`**
  Execution logic for the Attack action. Finds the nearest enemy and initiates an attack.

* **`perform_defend(attacker)`**
  Execution logic for the Defend action. Sets the defender flag.

* **`perform_flee(attacker)`**
  Execution logic for the Flee action. Has a 50% chance to end the battle.

* **`finish_action(c)`**
  Completes a combatant's turn, removing them from the ready list and checking for battle end.

* **`check_battle_end()`**
  Checks if either side has been wiped out. Ends combat if so.

## src/scenes/combat/Combatant.gd

Script for an individual character in combat.

* **`setup(p_data: CharacterData)`**
  Configures the combatant with data from `CharacterData`, setting HP bars and visual color.

* **`process_turn(delta) -> bool`**
  Updates the ATB gauge. Returns `true` if the ATB is full (ready to act), `false` otherwise.

* **`take_damage(amount)`**
  Applies damage to the character. damage is halved if defending.

* **`attack_target(target: Combatant)`**
  Performs an attack animation (move to target) and calls `take_damage` on the target.

* **`reset_atb()`**
  Resets the ATB gauge to 0 after an action.

## src/scenes/overworld/OverworldUI.gd

Manages the UI overlay in the overworld.

* **`_ready()`**
  Initializes UI elements, hiding panels by default.

* **`_input(event)`**
  Listens for key presses to toggle menus (Tab for Party, ESC for Pause).

* **`toggle_party_menu()`**
  Toggles the visibility of the party stats panel.

* **`toggle_pause_menu()`**
  Toggles the visibility of the pause menu.

* **`update_party_stats()`**
  Updates the text in the party panel with current stats of all party members.

* **`show_tooltip(entity)`**
  Displays a tooltip with information about the hovered entity (name, party composition).

* **`hide_tooltip()`**
  Hides the tooltip.

* **`_process(delta)`**
  Updates the tooltip position to follow the mouse and refreshes the time UI.

* **`update_time_ui()`**
  Updates the on-screen clock and day counter.

## src/scenes/overworld/OverworldPlayer.gd

Script for the player character in the overworld.

* **`_physics_process(delta)`**
  Handles player movement using input vectors and `move_and_slide`.

* **`try_interact()`**
  Checks for interactable areas in the `InteractionArea` and calls `interact()` on them.

## src/scenes/overworld/Overworld.gd

Manages the Overworld scene, loading maps and spawning entities.

* **`_ready()`**
  Called when the scene starts. Loads the current map data defined in `GameManager`.

* **`load_map_data(file_path: String)`**
  Reads a JSON file defining the map layout and entities.

* **`build_level(data: Dictionary)`**
  Parses map data to instantiate terrain and entities, clearing previous ones.

* **`spawn_entity(data: Dictionary)`**
  Instantiates a specific entity scene (based on type) at the specified coordinates.
