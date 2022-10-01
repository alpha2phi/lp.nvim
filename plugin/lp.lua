vim.api.nvim_create_user_command("LpRun", function()
  reload("lp")
  require("lp").run()
end, {})
