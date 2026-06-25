extends Control

## GSV Godot Cockpit — Main.gd
## The cockpit of GSV Sublime Optimization.
## Not the brain. The cockpit.
##
## Panels:
##   STATUS    — live service probes, agent roster
##   QUESTS    — colony reports as quest board
##   RECEIPTS  — audit trail from receipts.jsonl / sprint logs
##   TD        — Terminal Depths game-heart state
##   ROUTE     — natural-language routing to intermediary / gsv

const BRIDGE := "C:/GSV/tools/godot-cockpit/Invoke-GSVGodotBridge.ps1"

var _tabs: TabContainer
var _status_box: RichTextLabel
var _status_bar: Label
var _route_input: LineEdit
var _route_output: RichTextLabel

func _ready() -> void:
	_build_ui()
	_status_bar.text = "● online"
	_status_bar.modulate = Color(0.4, 1.0, 0.4)
	_append_status("[color=cyan]Ξ GSV Godot Cockpit[/color] — online.")
	_append_status("Bridge: " + BRIDGE)
	_append_status("Kilo_Core · GSV · Intermediary · FCC · LiteLLM · OpenClaw · Serena → [b]Cockpit[/b] → you")
	_append_status("─────────────────────────────────────")
	refresh_status()

# ── UI ────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 4)
	root.offset_left = 8; root.offset_top = 8
	root.offset_right = -8; root.offset_bottom = -8
	add_child(root)

	# Title
	var title := Label.new()
	title.text = "Ξ  GSV  Sublime Optimization  /  Colony Cockpit"
	title.add_theme_font_size_override("font_size", 18)
	root.add_child(title)

	# Status bar
	_status_bar = Label.new()
	_status_bar.text = "● booting..."
	_status_bar.modulate = Color(1.0, 0.8, 0.2)
	root.add_child(_status_bar)

	var sep := HSeparator.new()
	root.add_child(sep)

	# Tab container
	_tabs = TabContainer.new()
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_tabs)

	_build_status_tab()
	_build_agent_tab()
	_build_chug_tab()
	_build_quest_tab()
	_build_receipt_tab()
	_build_td_tab()
	_build_route_tab()

func _build_status_tab() -> void:
	var panel := VBoxContainer.new()
	panel.name = "Status"
	_tabs.add_child(panel)

	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 6)
	panel.add_child(btns)

	_add_btn(btns, "↺ Refresh",  refresh_status)
	_add_btn(btns, "⚡ Proof",    run_proof)
	_add_btn(btns, "🧹 Clear",    func(): _status_box.clear())

	_status_box = RichTextLabel.new()
	_status_box.use_bbcode = true
	_status_box.scroll_following = true
	_status_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(_status_box)

func _build_chug_tab() -> void:
	var panel := VBoxContainer.new()
	panel.name = "CHUG"
	_tabs.add_child(panel)
	var chug = load("res://scripts/CHUGPanel.gd").new()
	chug.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(chug)

func _build_agent_tab() -> void:
	var panel := VBoxContainer.new()
	panel.name = "Agents"
	_tabs.add_child(panel)
	var map = load("res://scripts/AgentMap.gd").new()
	map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(map)

func _build_quest_tab() -> void:
	var panel := VBoxContainer.new()
	panel.name = "Quests"
	_tabs.add_child(panel)
	var board = load("res://scripts/QuestBoard.gd").new()
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(board)

func _build_receipt_tab() -> void:
	var panel := VBoxContainer.new()
	panel.name = "Receipts"
	_tabs.add_child(panel)
	var viewer = load("res://scripts/ReceiptViewer.gd").new()
	viewer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(viewer)

func _build_td_tab() -> void:
	var panel := VBoxContainer.new()
	panel.name = "Terminal Depths"
	_tabs.add_child(panel)
	var td = load("res://scripts/TDStatePanel.gd").new()
	td.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(td)

func _build_route_tab() -> void:
	var panel := VBoxContainer.new()
	panel.name = "Route"
	panel.add_theme_constant_override("separation", 6)
	_tabs.add_child(panel)

	var info := Label.new()
	info.text = "Type a task. It routes through intermediary + gsv who-can."
	info.modulate = Color(0.7, 0.9, 1.0)
	panel.add_child(info)

	var input_row := HBoxContainer.new()
	panel.add_child(input_row)

	_route_input = LineEdit.new()
	_route_input.placeholder_text = "Route a task to the Greater System..."
	_route_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_route_input.text_submitted.connect(_do_route)
	input_row.add_child(_route_input)

	_add_btn(input_row, "Route ▶", func(): _do_route(_route_input.text))

	_route_output = RichTextLabel.new()
	_route_output.use_bbcode = true
	_route_output.scroll_following = true
	_route_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(_route_output)

func _add_btn(parent: Control, label: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = label
	b.pressed.connect(cb)
	parent.add_child(b)

# ── ACTIONS ───────────────────────────────────────────────────────────────────

func refresh_status() -> void:
	_status_bar.text = "● probing..."
	_status_bar.modulate = Color(1.0, 0.8, 0.2)
	var raw := _bridge("status", "")
	_append_status("\n[color=cyan]=== STATUS ===[/color]")
	_append_status(_parse_status(raw))
	_status_bar.text = "● live"
	_status_bar.modulate = Color(0.4, 1.0, 0.4)

func run_proof() -> void:
	_status_bar.text = "● proving..."
	var text := _bridge("proof", "")
	_append_status("\n[color=yellow]=== PROOF ===[/color]")
	_append_status(text)
	_status_bar.text = "● proof done"

func _do_route(obj: String = "") -> void:
	if obj.is_empty():
		obj = _route_input.text.strip_edges()
	if obj.is_empty():
		return
	_route_input.text = ""
	_route_output.append_text("\n[color=white]>>> %s[/color]\n" % obj)
	_status_bar.text = "● routing..."
	var text := _bridge("route", obj)
	_route_output.append_text("[color=green]=== ROUTE RESULT ===[/color]\n%s\n" % text)
	_status_bar.text = "● routed"

# ── BRIDGE ────────────────────────────────────────────────────────────────────

func _bridge(mode: String, objective: String) -> String:
	var args: Array[String] = ["-NoProfile","-ExecutionPolicy","Bypass","-File",BRIDGE,"-Mode",mode]
	if not objective.is_empty():
		args.append_array(["-Objective", objective])
	var output: Array = []
	var code := OS.execute("pwsh", args, output, true, false)
	if code != 0:
		output.clear()
		code = OS.execute("powershell", args, output, true, false)
	var text := ""
	for item in output:
		text += str(item)
	return text if not text.strip_edges().is_empty() else "(no output — exit %d)" % code

func _parse_status(raw: String) -> String:
	var json := JSON.new()
	if json.parse(raw) != OK:
		return raw
	var d = json.get_data()
	if typeof(d) != TYPE_DICTIONARY:
		return raw
	var lines: PackedStringArray = []
	lines.append("ts: " + str(d.get("ts","?")).substr(0,19))
	lines.append("services: [color=green]%d UP[/color] / [color=%s]%d DOWN[/color]" % [
		int(d.get("services_up",0)),
		"red" if int(d.get("services_down",0)) > 0 else "green",
		int(d.get("services_down",0))
	])
	var svcs = d.get("services", [])
	if typeof(svcs) == TYPE_ARRAY:
		for svc in svcs:
			if typeof(svc) == TYPE_DICTIONARY:
				var up: bool = svc.get("up", false)
				lines.append("  %s %s" % [
					"[color=green]✓[/color]" if up else "[color=red]✗[/color]",
					str(svc.get("name","?"))
				])
	lines.append("")
	lines.append("agents:")
	var cmds = d.get("commands", [])
	if typeof(cmds) == TYPE_ARRAY:
		var found_names: PackedStringArray = []
		var miss_names:  PackedStringArray = []
		for c in cmds:
			if typeof(c) == TYPE_DICTIONARY:
				if c.get("found", false): found_names.append(str(c.get("name","")))
				else:                     miss_names.append(str(c.get("name","")))
		lines.append("  [color=green]✓[/color] " + "  ".join(found_names))
		if not miss_names.is_empty():
			lines.append("  [color=gray]✗[/color] " + "  ".join(miss_names))
	return "\n".join(lines)

func _append_status(text: String) -> void:
	if _status_box:
		_status_box.append_text(text + "\n")
