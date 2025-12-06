# GameState.gd
extends Node

# Índice de arma elegido en el menú
var selected_weapon_index: int = 0
var selected_weapon_id: String = ""
#-------------Posicion prota-----------------
var player_position: Vector2 = Vector2.ZERO
#-------------Leveo-----------------

var xp: int         = 0
var level: int      = 1
var xp_to_next: int = 150

signal level_up(new_level: int)

func add_xp(amount: int) -> void:
	xp += amount
	print("➕ XP +%d → %d/%d (Nivel %d)" % [amount, xp, xp_to_next, level])
	if xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = int(xp_to_next * 1.2)
		print("🎉 ¡Subiste al nivel %d! Próximo nivel a %d XP" % [level, xp_to_next])
		emit_signal("level_up", level)
