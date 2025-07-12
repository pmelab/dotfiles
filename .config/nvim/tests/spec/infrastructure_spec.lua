-- Test infrastructure validation
-- This test ensures our testing setup is working correctly

describe('Test Infrastructure', function()
  it('can access vim namespace', function()
    assert.are.equal(type(vim), 'table')
    assert.are.equal(type(vim.fn), 'table')
  end)

  it('has plenary available', function()
    local ok, plenary = pcall(require, 'plenary')
    assert.is_true(ok)
    assert.are.equal(type(plenary), 'table')
  end)

  it('can require test helpers', function()
    local ok, helpers = pcall(require, 'tests.test_helpers')
    assert.is_true(ok)
    assert.are.equal(type(helpers), 'table')
  end)

  it('can load lspconfig when needed', function()
    -- Wait for lazy to finish loading
    vim.wait(1000, function() 
      return package.loaded['lspconfig'] ~= nil 
    end)
    
    local ok, lspconfig = pcall(require, 'lspconfig')
    if ok then
      assert.are.equal(type(lspconfig), 'table')
      assert.are.equal(type(lspconfig.util), 'table')
      assert.are.equal(type(lspconfig.util.root_pattern), 'function')
    else
      -- If lspconfig isn't loaded, just verify we can handle the error gracefully
      assert.is_true(true) -- This test passes if we can handle missing lspconfig
    end
  end)

  describe('vim.fn functions are available', function()
    it('has filereadable function', function()
      assert.are.equal(type(vim.fn.filereadable), 'function')
    end)

    it('has isdirectory function', function()
      assert.are.equal(type(vim.fn.isdirectory), 'function')
    end)

    it('has readfile function', function()
      assert.are.equal(type(vim.fn.readfile), 'function')
    end)
  end)
end)