local M = {}

local config = require("terminator.config")

function M.show()
	-- Prepare items for the picker
	local items = {}
	for id, terminal in pairs(config.terminals) do
		table.insert(items, {
			id = id,
			label = terminal.label,
			cwd = terminal.cwd,
			command = terminal.command,
		})
	end

	if #items == 0 then
		vim.notify("No terminals defined in " .. config.options.terminals_file, vim.log.levels.INFO)
		return
	end

	-- Format item for display in the picker
	local function format_item(item)
		local description = item.cwd .. (item.command and (" · " .. item.command) or "")
		return {
			display = item.label .. " (" .. description .. ")",
			value = item.id, -- Pass the terminal ID as the value
		}
	end

	-- Callback function when an item is selected
	local function on_select(result)
		-- result is the `value` from the selected item (the terminal ID)
		if result then
			require("terminator").create_terminal(result)
		end
	end

	-- Show the picker using Snacks.picker with a custom finder definition
	Snacks.picker({
		prompt = "Select Terminal ›",
		items = items,
		format = format_item,
		on_select = on_select,
	})
end

return M
