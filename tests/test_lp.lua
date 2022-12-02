local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()

local T = new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.lua([[M = require("lp")]])
    end,
    post_once = child.stop,
  },
})

local python_code_block = [[
print("python test")
]]

local javascript_code_block = [[
  console.log("javascript test")
]]

T["lp"] = new_set({ parametrize = { { python_code_block, "python", "python test" }, { javascript_code_block, "javascript", "javascript test" } } })

T["lp"]["works"] = function(code_block, lang, expected_output)
  MiniTest.expect.equality(child.lua_get([[M.run_code_block(...)]], { code_block, lang }), { expected_output })
end

return T
