-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- TODO: Debug php requests
-- TODO: Debug phpunit
-- TODO: Debug vitest
-- TODO: Debug typescript in node process
-- TODO: Debug typescript in chrome/storybook
-- TODO: which-key for code actions

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
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

-- Search for Drupal root directory in silverback projects
local function silverback_drupal_root(cwd)
	local root = require("lspconfig/util").root_pattern({ "pnpm-lock.yaml" })(cwd)
	if root and vim.fn.filereadable(root .. "/apps/silverback-drupal/composer.json") == 1 then
		return root .. "/apps/silverback-drupal"
	end
	if root and vim.fn.filereadable(root .. "/apps/cms/composer.json") == 1 then
		return root .. "/apps/cms"
	end
	if root then
		return root
	end
	return cwd
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
vim.diagnostic.config({ virtual_text = false })

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

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			init = function()
				vim.cmd.colorscheme("catppuccin-mocha")
			end,
		},
		{
			"williamboman/mason.nvim",
			opts = {},
		},
		{
			"stevearc/conform.nvim",
			cmd = { "ConformInfo" },
			event = { "BufWritePre" },
			---@module "conform"
			---@type conform.setupOpts
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					typescriptreact = { "prettierd" },
					javascriptreact = { "prettierd" },
					markdown = { "prettierd" },
					graphql = { "prettierd" },
					json = { "prettierd" },
					yaml = { "prettierd" },
					nix = { "nixfmt" },
					python = { "black" },
				},
				format_on_save = {
					timeout_ms = 500,
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
					"prettierd",
					"vtsls",
					"phpactor",
					"php-debug-adapter",
					"graphql-language-service-cli",
					"tailwindcss-language-server",
					"marksman",
					"pyright",
					"black",
					"debugpy",
				},
			},
		},
		{
			"nvim-lualine/lualine.nvim",
			init = function()
				require("lualine").setup({
					sections = {
						lualine_a = { "mode" },
						lualine_b = { "branch", "diff", "diagnostics" },
						lualine_c = { "filename" },
						lualine_x = { "filetype" },
						lualine_y = { "progress" },
						lualine_z = { "location" },
					},
					extensions = {
						"oil",
					},
				})
			end,
		},
		{
			"echasnovski/mini.nvim",
			version = "*",
			init = function()
				require("mini.icons").setup({})
				require("mini.pairs").setup({})
				require("mini.ai").setup({})
				require("mini.bracketed").setup({})
				require("mini.surround").setup({
					-- Module mappings. Use `''` (empty string) to disable one.
					mappings = {
						add = "ma", -- Add surrounding in Normal and Visual modes
						delete = "md", -- Delete surrounding
						highlight = "mh", -- Highlight surrounding
						replace = "mr", -- Replace surrounding
					},
					require("which-key").add({
						"mm",
						mode = { "n", "v" },
						"%",
					}),
				})
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
						Snacks.picker.lsp_symbols({
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
						})
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
				},
				buf_options = {
					buflisted = false,
					bufhidden = "hide",
				},
			},
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			keys = {
				{ "-", mode = { "n" }, "<CMD>Oil<CR>", { desc = "Open parent directory" } },
			},
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lsp" },
			init = function()
				-- Add cmp_nvim_lsp capabilities settings to lspconfig
				-- This should be executed before you configure any language server
				local lspconfig_defaults = require("lspconfig").util.default_config
				lspconfig_defaults.capabilities = vim.tbl_deep_extend(
					"force",
					lspconfig_defaults.capabilities,
					require("cmp_nvim_lsp").default_capabilities()
				)
				local wk = require("which-key")

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
				local lspconfig = require("lspconfig")
				-- Lua
				lspconfig.lua_ls.setup({})
				-- eslint
				lspconfig.eslint.setup({
					on_attach = function(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							command = "EslintFixAll",
						})
					end,
				})
				-- typescript
				lspconfig.vtsls.setup({})
				-- graphql
				lspconfig.graphql.setup({})
				-- php
				lspconfig.phpactor.setup({
					root_dir = function(cwd)
						return silverback_drupal_root(cwd)
					end,
				})
				lspconfig.tailwindcss.setup({})
				lspconfig.nil_ls.setup({})
				lspconfig.marksman.setup({})
				-- python
				lspconfig.pyright.setup({})

				local cmp = require("cmp")

				cmp.setup({
					sources = {
						{ name = "nvim_lsp" },
					},
					mapping = cmp.mapping.preset.insert({
						["<M-j>"] = cmp.mapping.select_next_item(),
						["<M-b>"] = cmp.mapping.scroll_docs(-4),
						["<M-f>"] = cmp.mapping.scroll_docs(4),
						["<M-l>"] = cmp.mapping.confirm({ select = true }),
						["<M-h>"] = cmp.mapping.complete({}),
					}),
				})
			end,
		},
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					"nvim-dap-ui",
					"snacks.nvim",
				},
			},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			init = function()
				local opts = {
					ensure_installed = {
						"graphql",
						"fish",
						"html",
						"markdown",
						"gitcommit",
						"python",
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
				require("gitsigns").setup({
					on_attach = function(bufnr)
						local gitsigns = require("gitsigns")
						local whichkey = require("which-key")
						whichkey.add({ "<leader>g", group = "Git" })
						local giticon = require("mini.icons").get("filetype", "Git")

						local function map(mode, lhs, rhs, desc)
							whichkey.add({
								mode = mode,
								lhs = lhs,
								rhs = rhs,
								desc = desc,
								buffer = bufnr,
								icon = giticon,
							})
						end

						-- Actions
						map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")

						map("n", "<leader>gb", function()
							gitsigns.blame_line({ full = true })
						end, "Blame line")
					end,
				})
			end,
		},
		{ "mfussenegger/nvim-dap" },
		{ "theHamsta/nvim-dap-virtual-text", opts = {} },
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
			config = function()
				local dap = require("dap")
				local dapui = require("dapui")
				dapui.setup({
					layouts = {
						{
							elements = {
								{ id = "scopes", size = 0.25 },
								"breakpoints",
								"stacks",
								"watches",
							},
							size = 40,
							position = "left",
						},
						{
							elements = {
								"repl",
								"console",
							},
							size = 0.25,
							position = "bottom",
						},
					},
					controls = { enabled = false }, -- Disable default controls, we'll map them
				})

				-- Don't open UI on entering debug mode
				dap.listeners.after.event_initialized["dapui_config"] = function() end
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close()
				end
				dap.listeners.before.event_exited["dapui_config"] = function()
					dapui.close()
				end

				local wk = require("which-key")
				local dap_icon = require("mini.icons").get("filetype", "Debug")

				wk.add({
					{ "<leader>d", group = "Debug", icon = dap_icon },
					{ "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", desc = "Toggle Breakpoint" },
					{
						"<leader>dB",
						'<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
						desc = "Set Conditional Breakpoint",
					},
					{ "<leader>dc", "<cmd>lua require('dap').continue()<CR>", desc = "Continue" },
					{ "<leader>dj", "<cmd>lua require('dap').step_over()<CR>", desc = "Step Over (j)" },
					{ "<leader>dl", "<cmd>lua require('dap').step_into()<CR>", desc = "Step Into (l)" },
					{ "<leader>dk", "<cmd>lua require('dap').step_out()<CR>", desc = "Step Out (k)" },
					{ "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>", desc = "Open REPL" },
					{ "<leader>dq", "<cmd>lua require('dap').terminate()<CR>", desc = "Quit" },
					{ "<leader>du", "<cmd>lua require('dapui').toggle()<CR>", desc = "Toggle UI" },
					{ "<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<CR>", desc = "Hover Variables (h)" },
					{
						"<leader>dD",
						"<cmd>lua require('dapui').eval(nil, { enter = true })<CR>",
						desc = "Evaluate Input",
					},
				})

				-- Map D to evaluate under cursor in a floating window
				vim.keymap.set("n", "D", function()
					require("dapui").eval(nil, { enter = false })
				end, { desc = "DAP Evaluate Hover" })
			end,
		},
		{
			"jay-babu/mason-nvim-dap.nvim",
			dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
			config = function()
				require("mason-nvim-dap").setup({
					ensure_installed = {
						"php-debug-adapter",
					},
					automatic_installation = true,
					handlers = {
						function(config)
							require("mason-nvim-dap").default_setup(config)
						end,
						php = function(config)
							-- config.configurations = {
							-- 	{
							-- 		type = "php",
							-- 		request = "launch",
							-- 		name = "PHP: Xdebug",
							-- 		port = 9003,
							-- 	},
							-- }
							require("mason-nvim-dap").default_setup(config)
						end,
						python = function(config)
							config.configurations = {
								{
									type = "python",
									request = "launch",
									name = "Launch file",
									program = "${file}",
									pythonPath = function()
										-- Try to use the active virtual environment's Python
										local venv = os.getenv("VIRTUAL_ENV")
										if venv then
											return venv .. "/bin/python"
										end
										-- Fall back to system Python
										return "/usr/bin/python3"
									end,
								},
							}
							require("mason-nvim-dap").default_setup(config)
						end,
					},
				})
			end,
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin-mocha" } },
})
