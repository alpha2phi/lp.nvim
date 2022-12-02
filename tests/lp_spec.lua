local lp = require("lp")

describe("Literate Programming", function()
  it("python", function()
    local code_block = [[
print("Python test")
]]

   local result = lp.run_code_block(code_block, "python")
   assert(vim.tbl_count(result) > 0, "Failed to interpret Python")
  end)

  it("javascript", function()
    local code_block = [[
      console.log("JavaScript test")
    ]]

   local result = lp.run_code_block(code_block, "javascript")
   assert(vim.tbl_count(result) > 0, "Failed to interpret JavaScript")
  end)
end)
