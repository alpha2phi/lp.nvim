vim.api.nvim_create_user_command("LpRun", function()
  require("lp").run()
end, {})
