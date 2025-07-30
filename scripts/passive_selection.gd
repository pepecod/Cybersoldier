# PassiveSelection.gd
extends Control
class_name PassiveSelection

signal choice_made(weapon_data)

# Aquí guardaremos las tres opciones que mostramos
var choices: Array = []

# El contenedor HBox que agrupa Opt0, Opt1 y Opt2
@onready var options_container: HBoxContainer = $PanelContainer/VBoxContainer/HBoxContainer

func setup(_choices: Array) -> void:
	choices = _choices
	for i in range(3):
		var opt = options_container.get_child(i) as Control
		if i < choices.size():
			opt.visible = true
			var spr = opt.get_child(0) as TextureRect
			var lbl = opt.get_child(1) as Label
			var btn = opt.get_child(2) as Button

			# Carga icono y descripción
			spr.texture = load(choices[i].icon_path)
			lbl.text    = choices[i].description

			# Primero desconectamos cualquier handler previo
			btn.pressed.disconnect_all()

			# Conectamos con una lambda que captura 'i'
			btn.pressed.connect(func() -> void:
				_on_option_selected(i)
			)
		else:
			opt.visible = false

func _on_option_selected(idx: int) -> void:
	emit_signal("choice_made", choices[idx])
	queue_free()
