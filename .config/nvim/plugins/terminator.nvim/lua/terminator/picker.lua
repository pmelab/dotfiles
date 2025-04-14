local M = {}

local config = require("terminator.config")

function M.show()
	-- ai! this does not work. look up how to use the picker from `folke/snacks.nvim` and implement it correctly
	local snacks = require("snacks")

	-- Prepare items for the picker
	local items = {}
	for id, terminal in pairs(config.terminals) do
		table.insert(items, {
			id = id,
			text = terminal.label,
			description = terminal.cwd .. (terminal.command and (" · " .. terminal.command) or ""),
		})
	end

	if #items == 0 then
		vim.notify("No terminals defined in " .. config.options.terminals_file, vim.log.levels.INFO)
		return
	end

	-- Show the picker using snacks.nvim
	snacks.select(items, {
		prompt = "Select Terminal",
		on_select = function(item)
			if item then
				require("terminator").create_terminal(item.id)
			end
		end,
	})
end

return M
