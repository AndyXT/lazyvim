-- my_cmd_runner.lua

-------------------------------------------------------------------------------
-- 1. Command history and utilities
-------------------------------------------------------------------------------
local COMMAND_HISTORY = {}
local HISTORY_INDEX = 1
local MAX_HISTORY = 50

local function add_to_history(cmd)
	-- Add to front of history
	table.insert(COMMAND_HISTORY, 1, cmd)
	-- Trim history if needed
	if #COMMAND_HISTORY > MAX_HISTORY then
		table.remove(COMMAND_HISTORY)
	end
	HISTORY_INDEX = 1
end

-------------------------------------------------------------------------------
-- 2. Utility to read JSON from a file
-------------------------------------------------------------------------------
local function load_commands_from_json(json_file)
	-- Attempt to read the file
	local ok, lines = pcall(vim.fn.readfile, json_file)
	if not ok then
		return nil, ("Failed to read file: %s"):format(json_file)
	end

	-- Combine lines and decode JSON
	local content = table.concat(lines, "\n")
	local ok_decode, data = pcall(vim.fn.json_decode, content)
	if not ok_decode then
		return nil, ("Failed to parse JSON in %s"):format(json_file)
	end

	-- Validate structure
	if not data.commands or type(data.commands) ~= "table" then
		return nil, ("JSON file %s doesn't contain a valid 'commands' array"):format(json_file)
	end

	-- Return the commands directly
	return data.commands, nil
end

-------------------------------------------------------------------------------
-- 3. Async wrapper for system calls with error handling
-------------------------------------------------------------------------------
local function run_system_async(cmd_args, callback)
	vim.system(cmd_args, { text = true }, function(obj)
		vim.schedule(function()
			if obj.code ~= 0 then
				callback({
					success = false,
					output = obj.stderr or "Command failed with no error output",
					code = obj.code,
				})
			else
				callback({
					success = true,
					output = obj.stdout == "" and "Command completed with no output" or obj.stdout,
					code = 0,
				})
			end
		end)
	end)
end

-------------------------------------------------------------------------------
-- 4. Popup creation helpers
-------------------------------------------------------------------------------

-- Create a footer window with keymap hints
local function create_footer(parent_win, parent_opts, keymaps)
	local buf = vim.api.nvim_create_buf(false, true)

	-- Format keymap text
	local keymap_text = {}
	for _, map in ipairs(keymaps) do
		table.insert(keymap_text, string.format("%s: %s", map[1], map[2]))
	end
	local footer_text = table.concat(keymap_text, " | ")

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { footer_text })

	-- Get parent window position
	local win_config = vim.api.nvim_win_get_config(parent_win)
	local parent_row = type(win_config.row) == "number" and win_config.row or win_config.row[false]
	local parent_col = type(win_config.col) == "number" and win_config.col or win_config.col[false]
	local parent_height = win_config.height

	-- Create footer window just below the parent
	local footer_win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = parent_opts.width,
		height = 1,
		row = parent_row + parent_height + 1,
		col = parent_col,
		style = "minimal",
		border = "rounded",
		focusable = false,
		zindex = 100,
	})

	vim.api.nvim_win_set_option(footer_win, "winhl", "Normal:FloatBorder")
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	return footer_win
end

-- The single create_popup function
local function create_popup(lines, keymaps_fn, opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.5)
	local height = opts.height or math.floor(vim.o.lines * 0.4)
	local row = opts.row or math.floor((vim.o.lines - height) / 2)
	local col = opts.col or math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)

	-- Set content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Buffer options
	local buf_opts = {
		modifiable = false,
		bufhidden = "wipe",
		buftype = "nofile",
		swapfile = false,
	}
	for opt, value in pairs(buf_opts) do
		vim.api.nvim_buf_set_option(buf, opt, value)
	end

	-- Window options
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = opts.border or "rounded",
	}

	-- Only add title options if title is set
	if opts.title then
		win_opts.title = opts.title
		win_opts.title_pos = opts.title_pos or "center"
	end

	local win_id = vim.api.nvim_open_win(buf, true, win_opts)

	-- Highlight
	if opts.highlight then
		vim.api.nvim_win_set_option(win_id, "winhl", "Normal:" .. opts.highlight)
	end

	-- Keymaps
	if keymaps_fn then
		keymaps_fn(buf, win_id, opts)
	end

	return buf, win_id
end

-------------------------------------------------------------------------------
-- 5. Main logic
-------------------------------------------------------------------------------
local COMMANDS = {}
local LAST_OUTPUT = {}
local STATUS_WINDOW = nil

-------------------------------------------------------------------------------
-- 5.1 Status indicator
-------------------------------------------------------------------------------
local function show_status(msg, level)
	if STATUS_WINDOW then
		vim.api.nvim_win_close(STATUS_WINDOW, true)
	end

	local lines = { msg }
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Create a small floating window for status
	STATUS_WINDOW = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = #msg + 2,
		height = 1,
		row = vim.o.lines - 2,
		col = 0,
		style = "minimal",
		border = "single",
	})

	-- Auto-close after 3 seconds
	vim.defer_fn(function()
		if STATUS_WINDOW and vim.api.nvim_win_is_valid(STATUS_WINDOW) then
			vim.api.nvim_win_close(STATUS_WINDOW, true)
			STATUS_WINDOW = nil
		end
	end, 3000)
end

-------------------------------------------------------------------------------
-- 5.2 Show Error Details Popup
-------------------------------------------------------------------------------
local function show_error_details(result)
	local lines = {
		"Command failed with code: " .. tostring(result.code),
		"Error output:",
		"-------------------",
	}
	vim.list_extend(lines, vim.split(result.output, "\n", { plain = true }))

	local popup_opts = {
		title = "Error Details",
		title_pos = "center",
		width = math.floor(vim.o.columns * 0.6),
		height = math.min(#lines + 2, math.floor(vim.o.lines * 0.4)),
		border = "rounded",
		highlight = "ErrorFloat",
	}

	local function keymaps(buf, win_id, opts)
		local function close_win()
			vim.api.nvim_win_close(win_id, true)
		end
		vim.keymap.set("n", "<Esc>", close_win, { buffer = buf, noremap = true, silent = true })
		vim.keymap.set("n", "q", close_win, { buffer = buf, noremap = true, silent = true })
	end

	create_popup(lines, keymaps, popup_opts)
end

-------------------------------------------------------------------------------
-- 5.3 Show Output Popup (after running a command)
-------------------------------------------------------------------------------
local function show_output_popup(result, on_close)
	local lines = vim.split(result.output, "\n", { plain = true })
	local title = result.success and "Command Output" or "Command Failed"
	local highlight = result.success and "Normal" or "ErrorFloat"

	if not result.success then
		table.insert(
			lines,
			1,
			"⚠️  Command failed with code " .. tostring(result.code) .. " (Press 'e' for details)"
		)
		table.insert(lines, 2, string.rep("-", 50))
	end

	local function keymaps(buf, win_id, opts)
		local keymap_list = {
			{ "p", "Pipe output" },
			{ "n", "Skip pipe" },
			{ "v", "Visual select" },
			{ "q", "Quit" },
		}

		local footer_win = create_footer(win_id, opts, keymap_list)
		vim.b[buf].footer_win = footer_win

		vim.api.nvim_buf_set_option(buf, "modifiable", false)
		vim.api.nvim_win_set_cursor(win_id, { 1, 0 })

		local function close_windows()
			if vim.api.nvim_win_is_valid(footer_win) then
				vim.api.nvim_win_close(footer_win, true)
			end
			if on_close then
				on_close()
			end
			vim.api.nvim_win_close(win_id, true)
		end

		-- Close mappings
		vim.keymap.set("n", "<Esc>", close_windows, { buffer = buf, noremap = true, silent = true })
		vim.keymap.set("n", "q", close_windows, { buffer = buf, noremap = true, silent = true })

		-- Error details if failed
		if not result.success then
			vim.keymap.set("n", "e", function()
				show_error_details(result)
			end, { buffer = buf, noremap = true, silent = true })
		end

		-- Pipe output mapping
		vim.keymap.set({ "n", "v" }, "p", function()
			local choices = {
				"Line at cursor",
				"Entire output",
				"Visual selection",
			}

			vim.ui.select(choices, { prompt = "Select what to pipe:" }, function(choice)
				if choice then
					if choice == "Line at cursor" then
						local cpos = vim.api.nvim_win_get_cursor(win_id)
						local line = lines[cpos[1]] or ""
						LAST_OUTPUT = { line }
						show_status("Piping current line", "info")
					elseif choice == "Visual selection" then
						local start_pos = vim.fn.getpos("'<")
						local end_pos = vim.fn.getpos("'>")
						local selected_lines = vim.api.nvim_buf_get_lines(buf, start_pos[2] - 1, end_pos[2], false)
						LAST_OUTPUT = selected_lines
						show_status("Piping selection", "info")
					else
						LAST_OUTPUT = lines
						show_status("Piping all output", "info")
					end
					close_windows()
				end
			end)
		end, { buffer = buf, noremap = true, silent = true })

		-- Skip piping
		vim.keymap.set("n", "n", function()
			LAST_OUTPUT = {}
			show_status("Skipping pipe", "info")
			close_windows()
		end, { buffer = buf, noremap = true, silent = true })
	end

	local popup_opts = {
		title = title,
		title_pos = "center",
		highlight = highlight,
		width = math.floor(vim.o.columns * 0.5),
		height = math.floor(vim.o.lines * 0.4),
		border = "rounded",
	}

	create_popup(lines, keymaps, popup_opts)
end

-------------------------------------------------------------------------------
-- 5.4 Run the selected command + show its output
-------------------------------------------------------------------------------
local function run_selected_command(cmd_table, on_done)
	show_status("Running command...", "info")

	local full_cmd
	if #LAST_OUTPUT > 0 then
		full_cmd = vim.list_extend(vim.deepcopy(cmd_table), LAST_OUTPUT)
	else
		full_cmd = cmd_table
	end

	run_system_async(full_cmd, function(result)
		show_output_popup(result, on_done)
	end)
end

-------------------------------------------------------------------------------
-- 5.5 Show command list popup
-------------------------------------------------------------------------------
local COMMANDS = {}
local LAST_OUTPUT = {}

local function show_command_list()
	local display_lines = {}
	for i, cmd in ipairs(COMMANDS) do
		local prefix = (#LAST_OUTPUT > 0) and "📎 " or "  "
		local cmd_str = table.concat(cmd.command, " ")
		local desc = cmd.description or ""
		display_lines[i] = string.format("%s%-30s │ %s", prefix, cmd_str, desc)
	end

	local function keymaps(buf, win_id, opts)
		local keymap_list = {
			{ "⏎", "Run command" },
			{ "c", "Clear pipe" },
			{ "q", "Quit" },
		}

		local footer_win = create_footer(win_id, opts, keymap_list)
		vim.b[buf].footer_win = footer_win

		local function close_windows()
			if vim.api.nvim_win_is_valid(footer_win) then
				vim.api.nvim_win_close(footer_win, true)
			end
			vim.api.nvim_win_close(win_id, true)
		end

		vim.keymap.set("n", "<Esc>", close_windows, { buffer = buf, noremap = true, silent = true })
		vim.keymap.set("n", "q", close_windows, { buffer = buf, noremap = true, silent = true })

		-- History navigation
		vim.keymap.set("n", "p", function()
			if #COMMAND_HISTORY > 0 then
				if HISTORY_INDEX < #COMMAND_HISTORY then
					HISTORY_INDEX = HISTORY_INDEX + 1
				end
				local hist_cmd = COMMAND_HISTORY[HISTORY_INDEX]
				if hist_cmd then
					for idx, c in ipairs(COMMANDS) do
						local arr = c.command or c
						if vim.deep_equal(arr, hist_cmd) then
							vim.api.nvim_win_set_cursor(win_id, { idx, 0 })
							break
						end
					end
				end
			end
		end, { buffer = buf, noremap = true, silent = true })

		vim.keymap.set("n", "n", function()
			if #COMMAND_HISTORY > 0 and HISTORY_INDEX > 1 then
				HISTORY_INDEX = HISTORY_INDEX - 1
				local hist_cmd = COMMAND_HISTORY[HISTORY_INDEX]
				if hist_cmd then
					for idx, c in ipairs(COMMANDS) do
						local arr = c.command or c
						if vim.deep_equal(arr, hist_cmd) then
							vim.api.nvim_win_set_cursor(win_id, { idx, 0 })
							break
						end
					end
				end
			end
		end, { buffer = buf, noremap = true, silent = true })

		-- Run command under cursor
		vim.keymap.set("n", "<CR>", function()
			local cursor = vim.api.nvim_win_get_cursor(win_id)
			local row = cursor[1]
			local selected_cmd = COMMANDS[row]
			if selected_cmd then
				local cmd_arr = selected_cmd.command
				add_to_history(cmd_arr)
				close_windows()
				run_selected_command(cmd_arr, function()
					show_command_list()
				end)
			end
		end, { buffer = buf, noremap = true, silent = true })

		-- Clear piped data
		vim.keymap.set("n", "c", function()
			LAST_OUTPUT = {}
			show_status("Cleared piped data", "info")
			close_windows()
			show_command_list()
		end, { buffer = buf, noremap = true, silent = true })
	end

	local popup_opts = {
		title = "Command List",
		title_pos = "center",
		width = math.floor(vim.o.columns * 0.5),
		height = math.floor(vim.o.lines * 0.4),
		border = "rounded",
	}

	create_popup(display_lines, keymaps, popup_opts)
end

-------------------------------------------------------------------------------
-- 6. Public entry point
-------------------------------------------------------------------------------
local function my_fancy_command()
	local cmd_file = vim.fn.getcwd() .. "/commands.json"
	-- print("Loading commands from:", cmd_file) -- Debug

	local list, err = load_commands_from_json(cmd_file)
	if err then
		vim.notify(err, vim.log.levels.ERROR)
		return
	end

	-- print("Loaded commands:", vim.inspect(list)) -- Debug

	COMMANDS = list
	if #COMMANDS == 0 then
		vim.notify("No commands found in JSON.", vim.log.levels.WARN)
		return
	end

	show_command_list()
end

-------------------------------------------------------------------------------
-- 7. Create user command
-------------------------------------------------------------------------------
vim.api.nvim_create_user_command("MyFancyCmd", function()
	my_fancy_command()
end, {})

-- Return module
return {
	my_fancy_command = my_fancy_command,
}
