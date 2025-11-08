extends Control
class_name PassiveSelection

signal choice_made(weapon_data)

var choices: Array = []

@onready var options_container: HBoxContainer = $PanelContainer/VBoxContainer/HBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hacer que el Control ocupe toda la pantalla
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Esperar a que se calcule el tamaño del panel
	await get_tree().process_frame
	
	# Centrar el PanelContainer
	if $PanelContainer:
		var viewport_size = get_viewport_rect().size
		$PanelContainer.position = (viewport_size - $PanelContainer.size) / 2

func setup(_choices: Array) -> void:
	choices = _choices
	
	for i in range(3):
		var opt = options_container.get_child(i) as Control
		
		if i < choices.size():
			opt.visible = true
			var spr = opt.get_child(0) as TextureRect
			var lbl = opt.get_child(1) as Label
			var btn = opt.get_child(2) as Button
			
			spr.texture = load(choices[i].icon_path)
			lbl.text = choices[i].description
			
			if not btn.pressed.is_connected(_on_option_selected):
				btn.pressed.connect(func() -> void: _on_option_selected(i))
		else:
			opt.visible = false

func _on_option_selected(idx: int) -> void:
	choice_made.emit(choices[idx])
	get_tree().paused = false
	queue_free()
