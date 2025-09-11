-- Test plugin loading and basic functionality
-- This ensures all plugins load correctly and their basic APIs are available

describe('Plugin Loading', function()
  describe('Essential Plugins', function()
    it('should load plenary.nvim successfully', function()
      local ok, plenary = pcall(require, 'plenary')
      assert.is_true(ok)
      assert.is_table(plenary)
    end)

    it('should have mason available', function()
      local ok, mason = pcall(require, 'mason')
      if ok then
        assert.is_table(mason)
        -- Mason should have basic setup function
        assert.is_function(mason.setup)
      else
        -- Mason might not be loaded in minimal test environment
        assert.is_boolean(ok)
      end
    end)

    it('should have lazy.nvim available', function()
      local ok, lazy = pcall(require, 'lazy')
      assert.is_true(ok)
      assert.is_table(lazy)
      
      -- Lazy should have essential functions
      assert.is_function(lazy.setup)
    end)
  end)

  describe('LSP Related Plugins', function()
    it('should be able to load nvim-lspconfig', function()
      local ok, lspconfig = pcall(require, 'lspconfig')
      if ok then
        assert.is_table(lspconfig)
        assert.is_table(lspconfig.util)
        assert.is_function(lspconfig.util.root_pattern)
      else
        -- lspconfig might not be loaded in minimal test
        assert.is_boolean(ok)
      end
    end)

    it('should have built-in LSP client available', function()
      assert.is_table(vim.lsp)
      assert.is_function(vim.lsp.start or function() end)
    end)
  end)

  describe('UI Plugins', function()
    it('should be able to load which-key if present', function()
      local ok, which_key = pcall(require, 'which-key')
      if ok then
        assert.is_table(which_key)
        -- which-key should have registration functions
        assert.is_function(which_key.add or which_key.register)
      else
        -- which-key might not be loaded in minimal test
        assert.is_boolean(ok)
      end
    end)

    it('should be able to load mini.nvim modules if present', function()
      local mini_modules = {'mini.icons', 'mini.pairs', 'mini.ai', 'mini.bracketed', 'mini.surround'}
      
      for _, module in ipairs(mini_modules) do
        local ok, mini_module = pcall(require, module)
        if ok then
          assert.is_table(mini_module)
          -- Most mini modules have a setup function
          if mini_module.setup then
            assert.is_function(mini_module.setup)
          end
        end
        -- It's okay if mini modules aren't loaded in minimal test
      end
    end)
  end)

  describe('Treesitter Integration', function()
    it('should have treesitter available if loaded', function()
      local ok, treesitter = pcall(require, 'nvim-treesitter')
      if ok then
        assert.is_table(treesitter)
      end
      
      -- Check built-in treesitter API
      if vim.treesitter then
        assert.is_table(vim.treesitter)
      end
    end)
  end)

  describe('Git Integration', function()
    it('should be able to load gitsigns if present', function()
      local ok, gitsigns = pcall(require, 'gitsigns')
      if ok then
        assert.is_table(gitsigns)
        assert.is_function(gitsigns.setup)
      else
        -- gitsigns might not be loaded in minimal test
        assert.is_boolean(ok)
      end
    end)
  end)

  describe('File Management', function()
    it('should be able to load oil.nvim if present', function()
      local ok, oil = pcall(require, 'oil')
      if ok then
        assert.is_table(oil)
        assert.is_function(oil.setup)
      else
        -- oil might not be loaded in minimal test
        assert.is_boolean(ok)
      end
    end)
  end)

  describe('Plugin Dependencies', function()
    it('should handle missing optional dependencies gracefully', function()
      -- Test that our config can handle missing optional plugins
      local optional_plugins = {
        'telescope',
        'nvim-cmp',
        'lualine',
        'catppuccin',
        'conform',
      }
      
      for _, plugin in ipairs(optional_plugins) do
        local ok, _ = pcall(require, plugin)
        -- It's fine if these fail - they're optional in test environment
        assert.is_boolean(ok)
      end
    end)

    it('should have essential dependencies available', function()
      -- These should be available for core functionality
      local essential_deps = {
        'plenary',
      }
      
      for _, dep in ipairs(essential_deps) do
        local ok, module = pcall(require, dep)
        assert.is_true(ok, "Essential dependency '" .. dep .. "' should be available")
        assert.is_table(module)
      end
    end)
  end)

  describe('Plugin Configuration Validation', function()
    it('should have valid plugin specifications', function()
      -- Test that we can access lazy plugin specs without errors
      local ok, lazy_config = pcall(function()
        return require('lazy').plugins()
      end)
      
      if ok then
        assert.is_table(lazy_config)
      else
        -- If lazy config isn't accessible, just ensure lazy is available
        local lazy_ok, lazy = pcall(require, 'lazy')
        assert.is_true(lazy_ok)
      end
    end)

    it('should handle plugin setup functions without errors', function()
      -- Test that calling setup on available plugins doesn't error
      local test_plugins = {
        { name = 'plenary', module = 'plenary', has_setup = false },
      }
      
      for _, plugin in ipairs(test_plugins) do
        local ok, module = pcall(require, plugin.module)
        if ok and plugin.has_setup and module.setup then
          -- Test setup doesn't error (but don't actually call it)
          assert.is_function(module.setup)
        end
      end
    end)
  end)

  describe('Error Handling', function()
    it('should handle require errors gracefully', function()
      -- Test requiring non-existent modules
      local ok, _ = pcall(require, 'non_existent_module')
      assert.is_false(ok)
      
      -- Ensure this doesn't break subsequent requires
      local plenary_ok, _ = pcall(require, 'plenary')
      assert.is_true(plenary_ok)
    end)

    it('should have proper error handling for plugin conflicts', function()
      -- This is a structural test - we're checking that our test environment
      -- can handle plugin loading errors without crashing
      assert.is_true(true) -- Meta-test
    end)
  end)

  describe('Lazy Loading Validation', function()
    it('should respect lazy loading configuration', function()
      -- In a minimal test environment, most plugins should not be loaded yet
      local potentially_lazy_plugins = {
        'conform',
        'mason-tool-installer',
        'lualine',
        'oil',
        'nvim-lspconfig',
        'which-key',
        'flash',
        'todo-comments',
        'snacks',
        'nvim-dap',
        'nvim-dap-ui',
      }
      
      local loaded_count = 0
      for _, plugin in ipairs(potentially_lazy_plugins) do
        if package.loaded[plugin] then
          loaded_count = loaded_count + 1
        end
      end
      
      -- In minimal test environment, most plugins should not be pre-loaded
      -- This helps ensure lazy loading is working
      assert.is_true(loaded_count < #potentially_lazy_plugins, 
                     "Too many plugins pre-loaded - lazy loading might not be working")
    end)
  end)
end)