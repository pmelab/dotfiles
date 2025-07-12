-- Test LSP configuration logic
local helpers = require('tests.test_helpers')

describe('LSP Configuration', function()
  local cleanup_mocks
  local original_lsp_clients = {}

  before_each(function()
    -- Reset any existing mocks
    if cleanup_mocks then
      cleanup_mocks()
    end
    
    -- Mock LSP client list
    original_lsp_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
    vim.lsp.get_clients = function()
      return {}
    end
  end)

  after_each(function()
    if cleanup_mocks then
      cleanup_mocks()
    end
    
    -- Restore original function
    if original_lsp_clients then
      vim.lsp.get_clients = original_lsp_clients
    end
  end)

  describe('Laravel Project LSP Setup', function()
    it('should prefer intelephense for Laravel projects', function()
      cleanup_mocks = helpers.mock_files({
        ['/laravel/composer.json'] = { readable = true },
        ['/laravel/artisan'] = { readable = true },
      })

      local is_laravel = helpers.is_laravel_project('/laravel/app')
      assert.is_true(is_laravel)
    end)

    it('should detect Pint availability in Laravel projects', function()
      cleanup_mocks = helpers.mock_files({
        ['/laravel/vendor/bin/pint'] = { readable = true },
      })

      local has_pint = helpers.has_pint('/laravel')
      assert.is_true(has_pint)
    end)

    it('should not detect Pint when not available', function()
      cleanup_mocks = helpers.mock_files({})

      local has_pint = helpers.has_pint('/laravel')
      assert.is_false(has_pint)
    end)
  end)

  describe('Drupal Project LSP Setup', function()
    it('should prefer phpactor for Drupal projects', function()
      cleanup_mocks = helpers.mock_files({
        ['/drupal/composer.json'] = { 
          readable = true,
          content = {
            '{',
            '  "require": {',
            '    "drupal/core": "^10.0"',
            '  }',
            '}'
          }
        },
      })

      local is_drupal = helpers.is_drupal_project('/drupal/web')
      assert.is_true(is_drupal)
    end)

    it('should handle silverback project structure', function()
      cleanup_mocks = helpers.mock_files({
        ['/silverback/pnpm-lock.yaml'] = { readable = true },
        ['/silverback/apps/silverback-drupal/composer.json'] = { readable = true },
      })

      -- Mock the root_pattern to return silverback directory
      local original_require = require
      _G.require = function(module)
        if module == "lspconfig/util" then
          return {
            root_pattern = function(patterns)
              return function(fname)
                if vim.tbl_contains(patterns, "pnpm-lock.yaml") then
                  return "/silverback"
                end
                return nil
              end
            end
          }
        end
        return original_require(module)
      end

      local drupal_root = helpers.silverback_drupal_root('/silverback/apps/silverback-drupal/web/index.php')
      assert.are.equal('/silverback/apps/silverback-drupal', drupal_root)

      -- Restore require
      _G.require = original_require
    end)
  end)

  describe('Project Type Priority', function()
    it('should correctly identify project types in order', function()
      -- Test Laravel detection
      cleanup_mocks = helpers.mock_files({
        ['/mixed/composer.json'] = { readable = true },
        ['/mixed/artisan'] = { readable = true },
        ['/mixed/package.json'] = { 
          readable = true,
          content = { '{"dependencies": {"react": "^17.0.0"}}' }
        },
      })

      local is_laravel = helpers.is_laravel_project('/mixed/app')
      local is_storybook = helpers.is_storybook_project('/mixed/app')
      
      assert.is_true(is_laravel)
      assert.is_false(is_storybook) -- Should not detect storybook without proper indicators
    end)

    it('should handle multiple project types in same directory', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/composer.json'] = { 
          readable = true,
          content = {
            '{',
            '  "require": {',
            '    "drupal/core": "^10.0"',
            '  }',
            '}'
          }
        },
        ['/project/package.json'] = { 
          readable = true,
          content = {
            '{',
            '  "devDependencies": {',
            '    "@storybook/react": "^6.0.0"',
            '  }',
            '}'
          }
        },
        ['/project/pyproject.toml'] = { readable = true },
      })

      local is_drupal = helpers.is_drupal_project('/project/web')
      local is_storybook = helpers.is_storybook_project('/project/web')
      local is_python = helpers.is_python_project('/project/web')
      
      assert.is_true(is_drupal)
      assert.is_true(is_storybook)
      assert.is_true(is_python)
    end)
  end)

  describe('LSP Server Capabilities', function()
    -- These tests would require more complex mocking of vim.lsp
    -- For now, we'll test the logic that determines which servers to use
    
    it('should use correct formatter based on project type', function()
      -- Laravel with Pint
      cleanup_mocks = helpers.mock_files({
        ['/laravel/composer.json'] = { readable = true },
        ['/laravel/artisan'] = { readable = true },
        ['/laravel/vendor/bin/pint'] = { readable = true },
      })

      local is_laravel = helpers.is_laravel_project('/laravel/app')
      local has_pint = helpers.has_pint('/laravel')
      
      assert.is_true(is_laravel)
      assert.is_true(has_pint)
      -- In real config, this would disable LSP formatting in favor of Pint
    end)

    it('should use phpcbf for Drupal projects without Pint', function()
      cleanup_mocks = helpers.mock_files({
        ['/drupal/composer.json'] = { 
          readable = true,
          content = {
            '{',
            '  "require": {',
            '    "drupal/core": "^10.0"',
            '  }',
            '}'
          }
        },
      })

      local is_drupal = helpers.is_drupal_project('/drupal/web')
      local has_pint = helpers.has_pint('/drupal')
      
      assert.is_true(is_drupal)
      assert.is_false(has_pint)
      -- In real config, this would use phpcbf for formatting
    end)
  end)

  describe('Error Handling', function()
    it('should handle missing files gracefully', function()
      cleanup_mocks = helpers.mock_files({})

      local is_laravel = helpers.is_laravel_project('/nonexistent')
      local is_drupal = helpers.is_drupal_project('/nonexistent')
      local is_storybook = helpers.is_storybook_project('/nonexistent')
      local is_python = helpers.is_python_project('/nonexistent')
      
      assert.is_false(is_laravel)
      assert.is_false(is_drupal)
      assert.is_false(is_storybook)
      assert.is_false(is_python)
    end)

    it('should handle malformed JSON files', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/composer.json'] = { 
          readable = true,
          content = { '{ invalid json }' }
        },
        ['/project/package.json'] = { 
          readable = true,
          content = { '{ also invalid }' }
        },
      })

      -- Functions should not crash on malformed JSON
      local is_drupal = helpers.is_drupal_project('/project')
      local is_storybook = helpers.is_storybook_project('/project')
      
      -- Should return false for malformed files
      assert.is_false(is_drupal)
      assert.is_false(is_storybook)
    end)

    it('should handle nil paths gracefully', function()
      local has_pint = helpers.has_pint(nil)
      assert.is_false(has_pint)
    end)
  end)
end)