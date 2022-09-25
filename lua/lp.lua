local M = {}

local query = [[
  ;; query
  (
  fenced_code_block
  (info_string (language) @language) 
  (code_fence_content) @content
  (fenced_code_block_delimiter) @delimiter
  )
]]

function M.setup()
	print("TODO")
end

return M
