local function show_result_in_popup(lines)
	-- Create a new scratch buffer (listed=false, scratch=true)
	local buf = vim.api.nvim_create_buf(false, true)

	-- Set buffer lines
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Calculate some size/position for the popup
	local width = math.floor(vim.o.columns * 0.5)
	local height = math.floor(vim.o.lines * 0.4)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Open a floating window showing the buffer
	local win_id = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	})

	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win_id, true)
	end, { buffer = buf, noremap = true, silent = true })
	-- Optional: Make the buffer modifiable or read-only
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
end

-- Next, a function to run a command with `vim.system()` and display the result
local function run_command_in_popup(cmd_args)
	-- `vim.system()` can be used synchronously or asynchronously.
	-- Below is the asynchronous pattern, which takes a callback.
	-- cmd_args should be a table, e.g. { "ls", "-la" }
	vim.system(cmd_args, { text = true }, function(obj)
		-- obj contains { code, signal, stdout, stderr }
		vim.schedule(function()
			local output = obj.stdout
			if output == "" then
				output = "No output"
			end

			-- Split the output into lines for the popup
			local lines = vim.split(output, "\n", { plain = true })

			-- Show in the popup
			show_result_in_popup(lines)
		end)
	end)
end
run_command_in_popup({ "ls", "-la" })
