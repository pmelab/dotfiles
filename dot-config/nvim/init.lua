-- Resolve mise tool paths directly, bypassing shell to avoid shim recursion
local mise_obj = vim.system({ "mise", "bin-paths" }, { text = true }):wait(3000)
if mise_obj.code == 0 then
	local paths = {}
	for line in mise_obj.stdout:gmatch("[^\n]+") do
		table.insert(paths, line)
	end
	for i = #paths, 1, -1 do
		vim.env.PATH = paths[i] .. ":" .. vim.env.PATH
	end
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"

-- Auto-reload files changed on disk
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd "checktime"
		end
	end,
})

-- Treesitter based code folding
vim.opt.foldenable = false
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"

-- Two space tabs.
vim.opt.tabstop = 2 -- Number of spaces that a <Tab> counts for
vim.opt.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs

-- Don't show errors inline, as its too distracting.
vim.diagnostic.config { virtual_text = false }

-- Clear search highlights with escape.
vim.api.nvim_set_keymap("n", "<Esc>", ":noh<CR>", { noremap = true, silent = true })

-- Make sure we can use ESC to exit terminal mode.
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- Set j and k to move per line through soft wraps.
vim.api.nvim_set_keymap("n", "j", "gj", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "k", "gk", { noremap = true, silent = true })

-- Disable line numbers and sign column in terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- Git status cache for oil.nvim
local function oil_parse_git_output(proc)
	local result = proc:wait()
	local ret = {}
	if result.code == 0 then
		for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
			line = line:gsub("/$", "")
			ret[line] = true
		end
	end
	return ret
end

local function oil_new_git_status()
	return setmetatable({}, {
		__index = function(self, key)
			local ignore_proc = vim.system(
				{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
				{ cwd = key, text = true }
			)
			local tracked_proc = vim.system(
				{ "git", "ls-tree", "HEAD", "--name-only" },
				{ cwd = key, text = true }
			)
			local ret = {
				ignored = oil_parse_git_output(ignore_proc),
				tracked = oil_parse_git_output(tracked_proc),
			}
			rawset(self, key, ret)
			return ret
		end,
	})
end

local oil_git_status = oil_new_git_status()

-- Setup lazy.nvim
require("lazy").setup {
	spec = {
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			init = function()
				vim.cmd.colorscheme "catppuccin-mocha"
			end,
		},
		{
			"b0o/schemastore.nvim",
			lazy = true,
		},
		{
			"williamboman/mason.nvim",
			opts = {},
		},
		{
			"stevearc/conform.nvim",
			enabled = true,
			cmd = { "ConformInfo" },
			event = { "BufWritePre" },
			---@module "conform"
			---@type conform.setupOpts
			opts = {
				formatters = {
					phpcbf = {
						cwd = function(self, ctx)
							-- Find the root directory containing phpcs.xml.dist or composer.json
							local root = vim.fs.root(ctx.filename, { "phpcs.xml.dist", "composer.json" })
							return root
						end,
					},
				},
				formatters_by_ft = {
					lua = { "stylua" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
					javascriptreact = { "prettier" },
					markdown = { "prettier" },
					graphql = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					python = { "black" },
					blade = { "blade-formatter" },
					php = function(bufnr)
						local fname = vim.api.nvim_buf_get_name(bufnr)
						local root_dir = vim.fs.root(fname, "composer.json")
						if root_dir and vim.fn.filereadable(root_dir .. "/vendor/bin/pint") == 1 then
							return { "pint" }
						end
						return { "phpcbf" }
					end,
				},
			format_on_save = {
				timeout_ms = 3000,
				lsp_format = "fallback",
			},
			},
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = {
				ensure_installed = {
					"stylua",
					"lua-language-server",
					"eslint-lsp",
					"prettier",
					"vtsls",
					"pint",
					"phpcbf",
					"graphql-language-service-cli",
					"tailwindcss-language-server",
					"marksman",
					"zk",
					"pyright",
					"black",
					"blade-formatter",
					"json-lsp",
					"yaml-language-server",
				},
			},
		},
		{
			"nvim-lualine/lualine.nvim",
			init = function()
				require("lualine").setup {
					sections = {
						lualine_a = { "mode" },
						lualine_b = { "branch", "diff", "diagnostics" },
						lualine_c = { { "filename", path = 1, shorting_target = 40 } },
						lualine_x = { "filetype" },
						lualine_y = { "progress" },
						lualine_z = { "location" },
					},
					extensions = {
						"oil",
					},
				}
			end,
		},
		{
			"echasnovski/mini.nvim",
			version = "*",
			init = function()
				require("mini.icons").setup {}
				require("mini.pairs").setup {}
				require("mini.ai").setup {}
				require("mini.bracketed").setup {}
				require("mini.surround").setup {
					-- Module mappings. Use `''` (empty string) to disable one.
					mappings = {
						add = "ma", -- Add surrounding in Normal and Visual modes
						delete = "md", -- Delete surrounding
						highlight = "mh", -- Highlight surrounding
						replace = "mr", -- Replace surrounding
					},
					require("which-key").add {
						"mm",
						mode = { "n", "v" },
						"%",
					},
				}
			end,
		},
		{
			"folke/flash.nvim",
			event = "VeryLazy",
			---@type Flash.Config
			opts = {},
			keys = {
				{
					"s",
					mode = { "n", "x", "o" },
					function()
						require("flash").jump()
					end,
					desc = "Flash",
				},
			},
		},
		{
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {},
		},
		{
			dir = vim.fn.expand("~/Code/review.nvim"),
			name = "review.nvim",
			keys = function()
				return require("review").lazy_keys()
			end,
			config = function()
				require("review").setup()
			end,
		},
		{
			"folke/snacks.nvim",
			---@type snacks.Config
			opts = {
				picker = {
					ui_select = true,
				},
				explorer = {},
			},
			keys = {
				-- Top Pickers & Explorer
				{
					"<leader><space>",
					function()
						Snacks.picker.smart()
					end,
					desc = "Smart Find Files",
				},
				{
					"<leader>,",
					function()
						Snacks.picker.buffers()
					end,
					desc = "Buffers",
				},
				{
					"<leader>/",
					function()
						Snacks.picker.grep()
					end,
					desc = "Grep",
				},
				{
					"<leader>:",
					function()
						Snacks.picker.command_history()
					end,
					desc = "Command History",
				},
				{
					"<leader>e",
					function()
						Snacks.explorer()
					end,
					desc = "File Explorer",
				},
				-- find
				{
					"<leader>fb",
					function()
						Snacks.picker.buffers()
					end,
					desc = "Buffers",
				},
				{
					"<leader>ff",
					function()
						Snacks.picker.files()
					end,
					desc = "Find Files",
				},
				{
					"<leader>fg",
					function()
						Snacks.picker.git_files()
					end,
					desc = "Find Git Files",
				},
				{
					"<leader>fr",
					function()
						Snacks.picker.recent()
					end,
					desc = "Recent",
				},
				-- Grep
				{
					"<leader>sb",
					function()
						Snacks.picker.lines()
					end,
					desc = "Buffer Lines",
				},
				{
					"<leader>sg",
					function()
						Snacks.picker.grep()
					end,
					desc = "Grep",
				},
				{
					"<leader>sw",
					function()
						Snacks.picker.grep_word()
					end,
					desc = "Visual selection or word",
					mode = { "n", "x" },
				},
				-- search
				{
					'<leader>s"',
					function()
						Snacks.picker.registers()
					end,
					desc = "Registers",
				},
				{
					"<leader>sc",
					function()
						Snacks.picker.command_history()
					end,
					desc = "Command History",
				},
				{
					"<leader>sC",
					function()
						Snacks.picker.commands()
					end,
					desc = "Commands",
				},
				{
					"<leader>sd",
					function()
						Snacks.picker.diagnostics()
					end,
					desc = "Diagnostics",
				},
				{
					"<leader>sD",
					function()
						Snacks.picker.diagnostics_buffer()
					end,
					desc = "Buffer Diagnostics",
				},
				{
					"<leader>sh",
					function()
						Snacks.picker.help()
					end,
					desc = "Help Pages",
				},
				{
					"<leader>si",
					function()
						Snacks.picker.icons()
					end,
					desc = "Icons",
				},
				{
					"<leader>sj",
					function()
						Snacks.picker.jumps()
					end,
					desc = "Jumps",
				},
				{
					"<leader>sk",
					function()
						Snacks.picker.keymaps()
					end,
					desc = "Keymaps",
				},
				{
					"<leader>sl",
					function()
						Snacks.picker.loclist()
					end,
					desc = "Location List",
				},
				{
					"<leader>sm",
					function()
						Snacks.picker.marks()
					end,
					desc = "Marks",
				},
				{
					"<leader>sq",
					function()
						Snacks.picker.qflist()
					end,
					desc = "Quickfix List",
				},
				{
					"<leader>sR",
					function()
						Snacks.picker.resume()
					end,
					desc = "Resume",
				},
				{
					"<leader>su",
					function()
						Snacks.picker.undo()
					end,
					desc = "Undo History",
				},
				-- LSP
				{
					"gd",
					function()
						Snacks.picker.lsp_definitions()
					end,
					desc = "Goto Definition",
				},
				{
					"gD",
					function()
						Snacks.picker.lsp_declarations()
					end,
					desc = "Goto Declaration",
				},
				{
					"gr",
					function()
						Snacks.picker.lsp_references()
					end,
					nowait = true,
					desc = "References",
				},
				{
					"gI",
					function()
						Snacks.picker.lsp_implementations()
					end,
					desc = "Goto Implementation",
				},
				{
					"gy",
					function()
						Snacks.picker.lsp_type_definitions()
					end,
					desc = "Goto T[y]pe Definition",
				},
				{
					"<leader>ss",
					function()
						Snacks.picker.lsp_symbols {
							finder = "lsp_symbols",
							format = "lsp_symbol",
							tree = true,
							filter = {
								default = {
									"Class",
									"Constructor",
									"Enum",
									"Field",
									"Function",
									"Interface",
									"Method",
									"Module",
									"Namespace",
									"Package",
									"Property",
									"Struct",
									"Trait",
								},
								-- set to `true` to include all symbols
								markdown = true,
								help = true,
							},
						}
					end,
					desc = "LSP Symbols",
				},
				{
					"<leader>sS",
					function()
						Snacks.picker.lsp_workspace_symbols()
					end,
					desc = "LSP Workspace Symbols",
				},
			},
		},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				preset = "helix",
			},
		},
		{
			"stevearc/oil.nvim",
			lazy = false,
			opts = {
				default_file_explorer = true,
				skip_confirm_for_simple_edits = true,
				view_options = {
					show_hidden = true,
					highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
						local oil = require("oil")
						local dir = oil.get_current_dir()
						if not dir then
							return nil
						end
						local status = oil_git_status[dir]
						if status.ignored[entry.name] then
							return "Comment"
						end
						-- Don't dim hidden files that are tracked
						if is_hidden and status.tracked[entry.name] then
							return "Normal"
						end
						return nil
					end,
				},
				buf_options = {
					buflisted = false,
					bufhidden = "hide",
				},
			},
			config = function(_, opts)
				local oil = require("oil")
				oil.setup(opts)
				local refresh = require("oil.actions").refresh
				local orig_refresh = refresh.callback
				refresh.callback = function(...)
					-- Clear cache by removing all keys
					for k in pairs(oil_git_status) do
						oil_git_status[k] = nil
					end
					orig_refresh(...)
				end
			end,
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			keys = {
				{ "-", mode = { "n" }, "<CMD>Oil<CR>", { desc = "Open parent directory" } },
			},
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lsp" },
			init = function()
				-- Add cmp_nvim_lsp capabilities settings to all language servers
				-- This should be executed before you configure any language server
				vim.lsp.config("*", {
					capabilities = require("cmp_nvim_lsp").default_capabilities(),
				})
				local wk = require "which-key"

				-- This is where you enable features that only work
				-- if there is a language server active in the file
				vim.api.nvim_create_autocmd("LspAttach", {
					desc = "LSP actions",
					callback = function(event)
						local opts = { buffer = event.buf }
						vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
						vim.keymap.set("n", "E", vim.diagnostic.open_float)
						vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
					end,
				})

				-- You'll find a list of language servers here:
				-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
				-- These are example language servers.

				-- Lua
				vim.lsp.config("lua_ls", {})
				vim.lsp.enable "lua_ls"
			-- eslint
			vim.lsp.config("eslint", {
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.execute_command {
								command = "eslint.applyAllFixes",
								arguments = {
									{
										uri = vim.uri_from_bufnr(bufnr),
										version = vim.lsp.util.buf_versions[bufnr],
									},
								},
							}
						end,
					})
				end,
			})
				vim.lsp.enable "eslint"
				-- typescript
				vim.lsp.config("vtsls", {})
				vim.lsp.enable "vtsls"
				-- graphql
				vim.lsp.config("graphql", {})
				vim.lsp.enable "graphql"
				vim.lsp.config("tailwindcss", {})
				vim.lsp.enable "tailwindcss"
				vim.lsp.config("nil_ls", {})
				vim.lsp.enable "nil_ls"
				-- Marksman LSP for all markdown files
				vim.lsp.config("marksman", {})
				vim.lsp.enable "marksman"
				-- python
				vim.lsp.config("pyright", {})
				vim.lsp.enable "pyright"
				-- json
				vim.lsp.config("jsonls", {
					settings = {
						json = {
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true },
						},
					},
				})
				vim.lsp.enable "jsonls"
				-- yaml
				vim.lsp.config("yamlls", {
					settings = {
						yaml = {
							schemaStore = {
								enable = true,
								url = "",
							},
							schemas = require("schemastore").yaml.schemas(),
						},
					},
				})
				vim.lsp.enable "yamlls"

				local cmp = require "cmp"

				cmp.setup {
					sources = {
						{ name = "nvim_lsp" },
					},
					formatting = {
						format = require("nvim-highlight-colors").format,
					},
					mapping = cmp.mapping.preset.insert {
						["<M-j>"] = cmp.mapping.select_next_item(),
						["<M-b>"] = cmp.mapping.scroll_docs(-4),
						["<M-f>"] = cmp.mapping.scroll_docs(4),
						["<M-l>"] = cmp.mapping.confirm { select = true },
						["<M-h>"] = cmp.mapping.complete {},
					},
				}
			end,
		},
		{
			"brenoprata10/nvim-highlight-colors",
			opts = {
				render = "virtual",
				virtual_symbol = "■",
				enable_tailwind = true,
			},
		},
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					"snacks.nvim",
				},
			},
		},
		{
			"jwalton512/vim-blade",
			ft = "blade",
		},
		{
			"nvim-treesitter/nvim-treesitter",
			init = function()
				local opts = {
					ensure_installed = {
						"bash",
						"css",
						"fish",
						"graphql",
						"html",
						"javascript",
						"json",
						"lua",
						"markdown",
						"markdown_inline",
						"mermaid",
						"nix",
						"php",
						"python",
						"scss",
						"tsx",
						"typescript",
						"vim",
						"vimdoc",
						"yaml",
						"gitcommit",
					},
					highlight = {
						enable = true,
					},
				}
				require("nvim-treesitter.configs").setup(opts)
			end,
		},
		{
			"lewis6991/gitsigns.nvim",
			init = function()
				require("gitsigns").setup {
					on_attach = function(bufnr)
						local gitsigns = require "gitsigns"
						local whichkey = require "which-key"
						whichkey.add { "<leader>g", group = "Git" }
						local giticon = require("mini.icons").get("filetype", "Git")

						local function map(mode, lhs, rhs, desc)
							whichkey.add {
								mode = mode,
								lhs = lhs,
								rhs = rhs,
								desc = desc,
								buffer = bufnr,
								icon = giticon,
							}
						end

						-- Actions
						map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")

						map("n", "<leader>gb", function()
							gitsigns.blame_line { full = true }
						end, "Blame line")

						map("n", "<leader>gs", function()
							gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "." }
						end, "Stage/unstage current line")
						map("v", "<leader>gs", function()
							gitsigns.stage_hunk { vim.fn.line "'<", vim.fn.line "'>" }
						end, "Stage/unstage selected lines")

						map("n", "<leader>gf", gitsigns.stage_buffer, "Stage file")
						map("n", "<leader>gh", function()
							local hunks = gitsigns.get_hunks()
							if not hunks or #hunks == 0 then
								vim.notify("No hunks in current file", vim.log.levels.INFO)
								return
							end

							local items = {}
							for i, hunk in ipairs(hunks) do
								local hunk_type = hunk.type
								local start_line = hunk.added.start
								local line_count = math.max(hunk.added.count, hunk.removed.count)
								local preview_lines = {}

								-- Create preview from hunk lines
								for _, line in ipairs(hunk.lines or {}) do
									table.insert(preview_lines, line)
								end

								table.insert(items, {
									idx = i,
									text = string.format(
										"%s: L%d-%d (%d lines)",
										hunk_type:upper(),
										start_line,
										start_line + line_count - 1,
										line_count
									),
									hunk = hunk,
									line = start_line,
									preview = { text = table.concat(preview_lines, "\n") },
								})
							end

							require("snacks").picker {
								title = "Git Hunks (Current File)",
								items = items,
								format = "text",
								preview = "preview",
								confirm = function(picker, item)
									picker:close()
									if item and item.line then
										vim.api.nvim_win_set_cursor(0, { item.line, 0 })
										vim.cmd "normal! zz"
									end
								end,
							}
						end, "Git hunks picker (current file)")

						-- Reset/drop changes
						map("n", "<leader>gr", function()
							gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "." }
						end, "Drop changes on current line")
						map("v", "<leader>gr", function()
							gitsigns.reset_hunk { vim.fn.line "'<", vim.fn.line "'>" }
						end, "Drop changes on selected lines")
					end,
				}

				-- Global git file picker (outside of buffer-specific mappings)
				local wk = require "which-key"
				local giticon = require("mini.icons").get("filetype", "Git")
				wk.add {
					{
						"<leader>gd",
						require("snacks").picker.git_status,
						desc = "Git Status",
						icon = giticon,
					},
					{
						"<leader>gn",
						function()
							require("gitsigns").nav_hunk "next"
						end,
						desc = "Next Unstaged Diff",
						icon = giticon,
					},
				}
			end,
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin-mocha" } },
}

