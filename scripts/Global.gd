extends Node

var player_current_attack = false
var current_scene = "world"
var transition_scene = false 

var player_exit_cliffside_posx = 144
var player_exit_cliffside_posy = 24
var player_start_posx = 30
var player_start_posy = 80

var game_first_loadin = true


func finish_changescenes():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "cliff_side"
		else:
			current_scene = "world"
		
