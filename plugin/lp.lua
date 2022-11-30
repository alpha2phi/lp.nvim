vim.api.nvim_create_user_command("LpRun", function(opts)
  local lang = opts.args
  if lang ~= "" then
    require("lp").run(lang)
  else
    require("lp").run_all()
  end
end, {
  nargs = "?",
  complete = function()
    return { "python", "javascript" }
  end,
})

vim.api.nvim_create_user_command("LpClean", function()
  require("lp").clean_all()
end, {})
