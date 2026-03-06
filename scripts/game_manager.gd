extends Node

var current_score = 0
var max_score = 0
var portal

func _ready():
	portal = get_tree().root.get_node("Game/Portal")
	if !portal:
		print("Error: Portal node not found.")
	max_score = get_max_score()
	Hud.set_score(current_score)
	Hud.set_max_score(max_score)

func add_score_point():
	current_score += 1
	print("Current score: " + str(current_score))
	portal.set_locked(current_score < max_score)
	Hud.set_score(current_score)

func restart_level():
	get_tree().reload_current_scene()
	current_score = 0
	print("Level restarted. Score reset to: " + str(current_score))
	Hud.set_score(current_score)
	Hud.reset_timer()

func get_max_score() -> int:
	var root = get_tree().root
	return count_coins(root)

func count_coins(node) -> int:
	var coin_count = 0
	if node is Coin:
		coin_count += 1
	for child in node.get_children():
		coin_count += count_coins(child)
	return coin_count
