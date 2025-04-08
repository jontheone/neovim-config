return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
        local function get_random_quote()
            local quotes = {
                "Success is not final, failure is not fatal: It is the courage to continue that counts.",
                "Believe you can and you're halfway there.",
                "The harder you work for something, the greater you'll feel when you achieve it.",
                "Don't watch the clock; do what it does. Keep going.",
                "Dream it. Wish it. Do it.",
                "Success doesn’t just find you. You have to go out and get it.",
                "Push yourself, because no one else is going to do it for you.",
                "Great things never come from comfort zones.",
                "Wake up with determination. Go to bed with satisfaction.",
                "Do something today that your future self will thank you for.",
                "Little things make big days.",
                "It’s going to be hard, but hard does not mean impossible.",
                "Don’t wait for opportunity. Create it.",
                "Sometimes we’re tested not to show our weaknesses, but to discover our strengths.",
                "The key to success is to focus on goals, not obstacles.",
                "You are capable of amazing things.",
                "Stay positive, work hard, make it happen.",
                "Don't stop when you're tired. Stop when you're done.",
                "You don't have to be great to start, but you have to start to be great.",
                "Doubt kills more dreams than failure ever will.",
                "Success is what comes after you stop making excuses.",
                "If you get tired, learn to rest, not to quit.",
                "The only limit to our realization of tomorrow is our doubts of today.",
                "Don’t limit your challenges. Challenge your limits.",
                "Go the extra mile. It’s never crowded.",
                "Difficult roads often lead to beautiful destinations.",
                "Your only limit is your mind.",
                "Push through the pain. You’ll thank yourself later.",
                "Be stronger than your excuses.",
                "Act as if what you do makes a difference. It does."
            }
            math.randomseed(os.time())
            local index = math.random(1, #quotes)
            return quotes[index]
        end
        require('dashboard').setup {
            theme = "doom",
            hide = {
                statusline = true,
                tabline = true,
                winbar = true
            },
            config ={
                header = {
                    [[      ___           ___           ___                                      ___     ]],
                    [[     /  /\         /  /\         /  /\          ___            ___        /  /\    ]],
                    [[    /  /::|       /  /::\       /  /::\        /  /\          /__/\      /  /::|   ]],
                    [[   /  /:|:|      /  /:/\:\     /  /:/\:\      /  /:/          \__\:\    /  /:|:|   ]],
                    [[  /  /:/|:|__   /  /::\ \:\   /  /:/  \:\    /  /:/           /  /::\  /  /:/|:|__ ]],
                    [[ /__/:/ |:| /\ /__/:/\:\ \:\ /__/:/ \__\:\  /__/:/  ___    __/  /:/\/ /__/:/_|::::\]],
                    [[ \__\/  |:|/:/ \  \:\ \:\_\/ \  \:\ /  /:/  |  |:| /  /\  /__/\/:/~~  \__\/  /~~/:/]],
                    [[     |  |:/:/   \  \:\ \:\    \  \:\  /:/   |  |:|/  /:/  \  \::/           /  /:/ ]],
                    [[     |__|::/     \  \:\_\/     \  \:\/:/    |__|:|__/:/    \  \:\          /  /:/  ]],
                    [[     /__/:/       \  \:\        \  \::/      \__\::::/      \__\/         /__/:/   ]],
                    [[    \__\/         \__\/         \__\/           ~~~~                     \__\/   ]],
                    [[ ]],
                    [[ ]],
                    --[[ ]]
                }
                ,
                center = {
--                    {
--                        icon = " ",
--                        desc = "Find files",
--                        key = "f",
--                        key_format = "%s",
--                        action = "FzfLua files"
--                    },
--                    {
--                        icon = " ",
--                        desc = "File explorer",
--                        key = "d",
--                        key_format =    "%s",
--                        action = "Oil"
--                    },
--                    {
--                        icon = " ",
--                        desc = "New note",
--                        key = "n",
--                        key_format =    "%s",
--                        action = function() vim.cmd("File "..vim.fn.input({prompt="File > "})) end
--                    }
                },
                --footer = {  [[ ]], [[ ]], get_random_quote() },
                footer = { get_random_quote() },
                vertical_center = true
            }
        }
    end,
    dependencies = { {'nvim-tree/nvim-web-devicons'}}
}
