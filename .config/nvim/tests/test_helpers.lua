-- Test helpers for Neovim configuration testing
local M = {}

-- Mock lspconfig.util.root_pattern for testing
local function mock_root_pattern(patterns)
	return function(fname)
		local dir = vim.fn.fnamemodify(fname, ":h")
		while dir ~= "/" and dir ~= "" do
			for _, pattern in ipairs(patterns) do
				if vim.fn.filereadable(dir .. "/" .. pattern) == 1 or vim.fn.isdirectory(dir .. "/" .. pattern) == 1 then
					return dir
				end
			end
			local parent = vim.fn.fnamemodify(dir, ":h")
			if parent == dir then break end
			dir = parent
		end
		return nil
	end
end

-- Search for Drupal root directory in silverback projects
function M.silverback_drupal_root(fname)
	local root = mock_root_pattern({ "pnpm-lock.yaml" })(fname)
	if root and vim.fn.filereadable(root .. "/apps/silverback-drupal/composer.json") == 1 then
		return root .. "/apps/silverback-drupal"
	end
	if root and vim.fn.filereadable(root .. "/apps/cms/composer.json") == 1 then
		return root .. "/apps/cms"
	end
	if root then
		return root
	end
	-- Fallback to composer.json root pattern if no pnpm-lock.yaml found
	return mock_root_pattern({ "composer.json" })(fname)
end

-- Check if Pint is available in the project
function M.has_pint(root_dir)
	if not root_dir then
		return false
	end
	return vim.fn.filereadable(root_dir .. "/vendor/bin/pint") == 1
end

-- Detect if current file is in a Laravel project
function M.is_laravel_project(cwd)
	local root = mock_root_pattern({ "artisan", "composer.json" })(cwd)
	if root and vim.fn.filereadable(root .. "/artisan") == 1 then
		return true
	end
	return false
end

-- Detect if current file is in a Drupal project
function M.is_drupal_project(cwd)
	local root = mock_root_pattern({ "composer.json" })(cwd)
	if root and vim.fn.filereadable(root .. "/composer.json") == 1 then
		-- Check if it's a Drupal project by looking for drupal/core in composer.json
		local composer_content = vim.fn.readfile(root .. "/composer.json")
		local composer_string = table.concat(composer_content, "\n")
		if string.find(composer_string, "drupal/core") then
			return true
		end
	end
	return false
end

-- Detect if current file is in a Storybook project
function M.is_storybook_project(cwd)
	local root = mock_root_pattern({ "package.json", ".storybook" })(cwd)
	if root then
		-- Check for .storybook directory
		if vim.fn.isdirectory(root .. "/.storybook") == 1 then
			return true
		end
		-- Check for storybook in package.json
		if vim.fn.filereadable(root .. "/package.json") == 1 then
			local package_content = vim.fn.readfile(root .. "/package.json")
			local package_string = table.concat(package_content, "\n")
			if string.find(package_string, "@storybook") or string.find(package_string, "storybook") then
				return true
			end
		end
	end
	return false
end

-- Detect if current file is in a Python project
function M.is_python_project(cwd)
	local root = mock_root_pattern({
		"pyproject.toml",
		"requirements.txt",
		"setup.py",
		"Pipfile",
		"poetry.lock",
	})(cwd)
	if root then
		return true
	end
	return false
end

-- Mock file system helpers for testing
function M.mock_files(files)
	local original_filereadable = vim.fn.filereadable
	local original_isdirectory = vim.fn.isdirectory
	local original_readfile = vim.fn.readfile

	vim.fn.filereadable = function(path)
		return files[path] and files[path].readable and 1 or 0
	end

	vim.fn.isdirectory = function(path)
		return files[path] and files[path].is_directory and 1 or 0
	end

	vim.fn.readfile = function(path)
		if files[path] and files[path].content then
			return files[path].content
		end
		return {}
	end

	-- Return cleanup function
	return function()
		vim.fn.filereadable = original_filereadable
		vim.fn.isdirectory = original_isdirectory
		vim.fn.readfile = original_readfile
	end
end

return M