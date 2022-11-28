local M = {}

local SUPPORTED_LANGS = { "python", "javascript", "typescript" }

local markdown_code_block = [[
  (
  fenced_code_block
  (info_string (language) @language) (#eq? @language "%s")
  (code_fence_content) @content
  (fenced_code_block_delimiter) @delimiter
  )
]]

local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "markdown", {})
  local tree = parser:parse()[1]
  return tree:root()
end

local create_tmp_file = function(content)
  local tmp_file = os.tmpname()
  local f = io.open(tmp_file, "w")
  if f ~= nil then
    f:write(content)
    f:write("\n")
    f:close()
    return tmp_file
  end
  return nil
end

M.config = {}

M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.run_code_block = function(text, lang)
  local opts = {}
  local timeout = 150000
  local split = vim.split(text, "\n")
  local code_block = table.concat(vim.list_slice(split, 1, #split), "\n")
  if lang == "python" then
    opts = {
      command = "python",
      args = { "-c", code_block },
      timeout = timeout,
    }
  elseif lang == "javascript" or lang == "typescript" then
    local tmp_file = create_tmp_file(code_block)
    if tmp_file == nil then
      vim.notify("Unable to create temporary file!")
      return {}
    end
    opts = {
      command = "node",
      args = { tmp_file },
      timeout = timeout,
    }
  end
  local job = require("plenary.job"):new(opts)
  return job:sync()
end

M.run = function(bufnr, lang)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "markdown" then
    vim.notify("Only Markdown is supported")
    return
  end
  local root = get_root(bufnr)
  local target_code_block = string.format(markdown_code_block, lang)
  local markdown_query = vim.treesitter.parse_query("markdown", target_code_block)
  for id, node in markdown_query:iter_captures(root, bufnr, 0, -1) do
    local name = markdown_query.captures[id]
    if name == "content" then
      local range = { node:range() }
      local code_block = vim.treesitter.get_node_text(node, bufnr)
      local result = M.run_code_block(code_block, lang)
      table.insert(result, 1, "```text")
      table.insert(result, 1, "")
      table.insert(result, #result + 1, "```")
      vim.api.nvim_buf_set_lines(bufnr, range[3] + 1, range[3] + 1, false, result)
    end
  end
end

M.run_all = function(bufnr)
  for _, v in ipairs(SUPPORTED_LANGS) do
    M.run(bufnr, v)
  end
end

return M
