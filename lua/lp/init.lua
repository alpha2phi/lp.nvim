-- MIT License Copyright (c) 2022 Alpha2phi

-- Documentation ==============================================================
--- Generate output for embedded code snippets
---
--- lp.nvim is a plugin to generate code output for embedded code snippets in Markdown
--- document
---
--- Currently support:
--- - JavaScript
--- - Python
---
--- Available commands:
--- - LpRun <lang>
--- - LpClean
---
---@tag lp.nvim

local M = {}

local SUPPORTED_LANGS = { "python", "javascript" }

local markdown_code_block = [[
  (
  fenced_code_block
  (info_string (language) @language) (#eq? @language "%s")
  (code_fence_content) @code_content
  (fenced_code_block_delimiter) @delimiter
  ) @code_block
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

--- Module configuration.
M.config = {}

--- Set up the module.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

--- Create a plenary job to generate code output based on the language.
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
  elseif lang == "javascript" then
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

--- Parse the buffer for a particular language and generate the code output.
M.run = function(lang, bufnr)
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
    local range = { node:range() }
    if name == "code_content" and lang ~= "text" then
      local code_content = vim.treesitter.get_node_text(node, bufnr)
      local result = M.run_code_block(code_content, lang)
      table.insert(result, 1, "```text")
      table.insert(result, 1, "")
      table.insert(result, #result + 1, "```")
      vim.api.nvim_buf_set_lines(bufnr, range[3] + 1, range[3] + 1, false, result)
    elseif name == "code_block" and lang == "text" then
      vim.api.nvim_buf_set_lines(bufnr, range[1], range[3], false, {})
    end
  end
end

--- Remove generated code output.
M.clean_all = function(bufnr)
  M.run("text", bufnr)
end

--- Run code snippets for all languages.
M.run_all = function(bufnr)
  for _, v in ipairs(SUPPORTED_LANGS) do
    M.run(v, bufnr)
  end
end

return M
