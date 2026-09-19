return {
    { -- The task runner we use
      "stevearc/overseer.nvim",
      commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
      opts = {
        task_list = {
          direction = "bottom",
          min_height = 25,
          max_height = 25,
          default_detail = 1
        },
      },
      config = function()
          require("overseer").setup()
      end
    },
}
