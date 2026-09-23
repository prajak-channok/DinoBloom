extends AudioStreamPlayer

func _ready():
	# Check all node in tree and new node that create by code
	# (เช็คโหนดที่มีอยู่แล้ว และโหนดที่ถูกเพิ่มเข้าด้วยโค้ดทีหลัง)
	get_tree().node_added.connect(_on_node_added)
	_connect_buttons_in_tree(get_tree().root)


# ========================== Connecting node with sound ============================================

func _on_node_added(node: Node):
	_connect_button(node)

func _connect_buttons_in_tree(node: Node):
	_connect_button(node)
	
	for child in node.get_children():
		_connect_buttons_in_tree(child)  # "Recursion" (การเรียกฟังก์ชันตัวเอง) for "Depth-First Search"

func _connect_button(node: Node):
	if node is BaseButton:
		if not node.mouse_entered.is_connected(play_hover_sound):
			node.mouse_entered.connect(play_hover_sound)

func play_hover_sound():
	play()
