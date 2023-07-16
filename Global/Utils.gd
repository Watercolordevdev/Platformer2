extends Node

var file

const SAVE_PATH = "user://savegame.bin"

func saveGame():
	file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"PlayerHP": Game.PlayerHP,
		"Gold": Game.Gold,
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)

func loadGame():
	file = FileAccess.open(SAVE_PATH, FileAccess.READ)
