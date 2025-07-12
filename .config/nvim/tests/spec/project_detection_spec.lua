-- Test project detection functions
local helpers = require('tests.test_helpers')

describe('Project Detection Functions', function()
  local cleanup_mocks

  before_each(function()
    -- Reset any existing mocks
    if cleanup_mocks then
      cleanup_mocks()
    end
  end)

  after_each(function()
    if cleanup_mocks then
      cleanup_mocks()
    end
  end)

  describe('Laravel Project Detection', function()
    it('detects Laravel project with artisan file', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/composer.json'] = { readable = true },
        ['/project/artisan'] = { readable = true },
      })

      local result = helpers.is_laravel_project('/project/src')
      assert.is_true(result)
    end)

    it('does not detect Laravel without artisan file', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/composer.json'] = { readable = true },
      })

      local result = helpers.is_laravel_project('/project/src')
      assert.is_false(result)
    end)

    it('detects Laravel with only artisan file (loose detection)', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/artisan'] = { readable = true },
        -- No composer.json file - function still returns true
      })

      local result = helpers.is_laravel_project('/project/src')
      assert.is_true(result) -- Current function behavior: only requires artisan
    end)

    it('detects Laravel with both artisan and composer.json', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/composer.json'] = { readable = true },
        ['/project/artisan'] = { readable = true },
      })

      local result = helpers.is_laravel_project('/project/src')
      assert.is_true(result)
    end)
  end)

  describe('Drupal Project Detection', function()
    it('detects Drupal project with drupal/core in composer.json', function()
      cleanup_mocks = helpers.mock_files({
        ['/drupal/composer.json'] = { 
          readable = true,
          content = {
            '{',
            '  "require": {',
            '    "drupal/core": "^9.0",',
            '    "other/package": "^1.0"',
            '  }',
            '}'
          }
        },
      })

      local result = helpers.is_drupal_project('/drupal/web')
      assert.is_true(result)
    end)

    it('does not detect Drupal without drupal/core in composer.json', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/composer.json'] = { 
          readable = true,
          content = {
            '{',
            '  "require": {',
            '    "some/package": "^1.0"',
            '  }',
            '}'
          }
        },
      })

      local result = helpers.is_drupal_project('/project/web')
      assert.is_false(result)
    end)

    it('does not detect Drupal without composer.json', function()
      cleanup_mocks = helpers.mock_files({})

      local result = helpers.is_drupal_project('/project')
      assert.is_false(result)
    end)
  end)

  describe('Storybook Project Detection', function()
    it('detects Storybook with .storybook directory', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/.storybook'] = { is_directory = true },
        ['/project/package.json'] = { readable = true },
      })

      local result = helpers.is_storybook_project('/project/src')
      assert.is_true(result)
    end)

    it('detects Storybook with @storybook in package.json', function()
      cleanup_mocks = helpers.mock_files({
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
      })

      local result = helpers.is_storybook_project('/project/src')
      assert.is_true(result)
    end)

    it('detects Storybook with storybook in package.json', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/package.json'] = { 
          readable = true,
          content = {
            '{',
            '  "scripts": {',
            '    "storybook": "start-storybook"',
            '  }',
            '}'
          }
        },
      })

      local result = helpers.is_storybook_project('/project/src')
      assert.is_true(result)
    end)

    it('does not detect Storybook without indicators', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/package.json'] = { 
          readable = true,
          content = {
            '{',
            '  "dependencies": {',
            '    "react": "^17.0.0"',
            '  }',
            '}'
          }
        },
      })

      local result = helpers.is_storybook_project('/project/src')
      assert.is_false(result)
    end)
  end)

  describe('Python Project Detection', function()
    it('detects Python project with pyproject.toml', function()
      cleanup_mocks = helpers.mock_files({
        ['/python-project/pyproject.toml'] = { readable = true },
      })

      local result = helpers.is_python_project('/python-project/src')
      assert.is_true(result)
    end)

    it('detects Python project with requirements.txt', function()
      cleanup_mocks = helpers.mock_files({
        ['/python-project/requirements.txt'] = { readable = true },
      })

      local result = helpers.is_python_project('/python-project/app')
      assert.is_true(result)
    end)

    it('detects Python project with setup.py', function()
      cleanup_mocks = helpers.mock_files({
        ['/python-project/setup.py'] = { readable = true },
      })

      local result = helpers.is_python_project('/python-project/src')
      assert.is_true(result)
    end)

    it('detects Python project with Pipfile', function()
      cleanup_mocks = helpers.mock_files({
        ['/python-project/Pipfile'] = { readable = true },
      })

      local result = helpers.is_python_project('/python-project/src')
      assert.is_true(result)
    end)

    it('detects Python project with poetry.lock', function()
      cleanup_mocks = helpers.mock_files({
        ['/python-project/poetry.lock'] = { readable = true },
      })

      local result = helpers.is_python_project('/python-project/src')
      assert.is_true(result)
    end)

    it('does not detect Python project without indicators', function()
      cleanup_mocks = helpers.mock_files({
        ['/project/package.json'] = { readable = true },
      })

      local result = helpers.is_python_project('/project')
      assert.is_false(result)
    end)
  end)

  describe('Pint Detection', function()
    it('detects Pint when vendor/bin/pint exists', function()
      cleanup_mocks = helpers.mock_files({
        ['/laravel/vendor/bin/pint'] = { readable = true },
      })

      local result = helpers.has_pint('/laravel')
      assert.is_true(result)
    end)

    it('does not detect Pint when file does not exist', function()
      cleanup_mocks = helpers.mock_files({})

      local result = helpers.has_pint('/laravel')
      assert.is_false(result)
    end)

    it('handles nil root_dir gracefully', function()
      local result = helpers.has_pint(nil)
      assert.is_false(result)
    end)
  end)

  describe('Silverback Drupal Root Detection', function()
    it('finds silverback-drupal app directory', function()
      cleanup_mocks = helpers.mock_files({
        ['/silverback/pnpm-lock.yaml'] = { readable = true },
        ['/silverback/apps/silverback-drupal/composer.json'] = { readable = true },
      })

      -- Mock root_pattern to return the silverback directory
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

      local result = helpers.silverback_drupal_root('/silverback/apps/silverback-drupal/web/index.php')
      assert.are.equal('/silverback/apps/silverback-drupal', result)

      -- Restore require
      _G.require = original_require
    end)

    it('finds cms app directory as fallback', function()
      cleanup_mocks = helpers.mock_files({
        ['/silverback/pnpm-lock.yaml'] = { readable = true },
        ['/silverback/apps/cms/composer.json'] = { readable = true },
      })

      -- Mock root_pattern to return the silverback directory
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

      local result = helpers.silverback_drupal_root('/silverback/apps/cms/web/index.php')
      assert.are.equal('/silverback/apps/cms', result)

      -- Restore require
      _G.require = original_require
    end)
  end)
end)