return { 
    "stevearc/overseer.nvim",
    opts = {},
    config = function()
        local overseer = require("overseer")
        overseer.setup({
        task_list = {
          direction = "bottom",
          min_height = 0.3, 
          max_height = 0.3,
        },
        })

        vim.keymap.set("n", "<leader>e", ":OverseerToggle<CR>")
        vim.keymap.set("n", "<leader>w", "<cmd>OverseerRun cmakebuild<CR>")

        overseer.register_template({
            name = "cmakefresh",
            builder = function()
                local cwd = vim.uv.cwd()
                local build = vim.fs.joinpath(cwd, "build")

                if vim.fn.isdirectory(build) == 0 then
                    vim.fn.mkdir(build)
                else
                    vim.fs.rm(build, {recursive = true})
                    vim.fn.mkdir(build)
                end

                return {
                    cmd = {"cmake"},
                    args = {"-B", "build", "-G", "MinGW Makefiles"},
                    components = { { "on_output_quickfix" , open = false},
                                   { "run_after", detach = true, task_names = { "cmakebuild" } },
                                   { "unique", replace = false },
                                   "default"}
                }
            end,
            condition = {
                dir = vim.fn.getcwd()
            }
        })

        overseer.register_template({
            name = "cmakebuild",
            builder = function()
                return {
                    cmd = {"cmake"},
                    args = {"--build", "build"},
                    components = { {"run_after",  detach = false, task_names = { "buildrun" } },
                                   { "open_output", focust = true, on_start="always"},
                                   { "unique", replace = false },
                                   "default"}

                }
            end
        })

        overseer.register_template({
            name = "buildrun",
            builder = function()
                return {
                    cmd = {"./build/app.exe"},
                    components = { { "open_output", focus = true, on_start="always" },
                                   { "unique", replace = false },
                                   "default"}
                }
            end
        })

        vim.api.nvim_create_user_command("OS", function(args)
            local task = overseer.new_task({
                cmd = args.fargs,
                components = { {"open_output", focus = false},"default" }
            }):start()
        end, {desc = "Run a command on the OS", nargs="+"})

        vim.api.nvim_create_user_command("Cmakefresh", "OverseerRun cmakefresh", {desc = "start a fresh build of cmake with overseer"})
        vim.api.nvim_create_user_command("Cmake", "OverseerRun cmakebuild", {desc = "build with cmake and the run the executable, all with overseer"})
    end
}
