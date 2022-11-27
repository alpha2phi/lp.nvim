local M = {}

local markdown_code_block = [[
  (
  fenced_code_block
  (info_string (language) @language) (#eq? @language "python")
  (code_fence_content) @content
  (fenced_code_block_delimiter) @delimiter
  )
]]

local markdown_query = vim.treesitter.parse_query("markdown", markdown_code_block)

local run_code_block = function(text)
  local split = vim.split(text, "\n")
  local code_block = table.concat(vim.list_slice(split, 1, #split), "\n")
  local job = require("plenary.job"):new({
    command = "python",
    args = { "-c", code_block },
  })
  return job:sync()
end

M.config = {}

M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "markdown", {})
  local tree = parser:parse()[1]
  return tree:root()
end

M.run = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "markdown" then
    vim.notify("Only Markdown is supported")
    return
  end
  local root = get_root(bufnr)
  for id, node in markdown_query:iter_captures(root, bufnr, 0, -1) do
    local name = markdown_query.captures[id]
    if name == "content" then
      local range = { node:range() }
      local code_block = vim.treesitter.get_node_text(node, bufnr)
      local result = run_code_block(code_block)
      table.insert(result, 1, "```text")
      table.insert(result, 1, "")
      table.insert(result, #result + 1, "```")
      vim.api.nvim_buf_set_lines(bufnr, range[3] + 1, range[3] + 1, false, result)
    end
  end
end

return M
