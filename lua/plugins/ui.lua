-- UI plugins: telescope, harpoon, trouble, oil, which-key

return {
    -- Telescope - Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        --version = "0.1.6",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- Telescope symbols
    { "nvim-telescope/telescope-symbols.nvim" },

    -- Harpoon - Quick file navigation (custom fork)
    {
        "kolbbond/harpoon2",
        branch = "master",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- Trouble - Diagnostics list
    { "folke/trouble.nvim" },

    -- Oil - Directory editor
    { "stevearc/oil.nvim" },

    -- Neo-tree - File explorer sidebar
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
            { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal file in explorer" },
        },
        opts = {
            filesystem = {
                follow_current_file = { enabled = true },
                hijack_netrw_behavior = "disabled",
            },
            window = {
                width = 30,
                mappings = {
                    ["<space>"] = "none",
                },
            },
        },
    },

    -- Which-key - Show keybindings
    { "folke/which-key.nvim" },

    -- Toggleterm - Terminal integration
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup()
        end
    },

    -- project.nvim - Auto-detect and manage projects
    {
        "ahmedkhalf/project.nvim",
        config = function()
            require("project_nvim").setup({
                detection_methods = { "lsp", "pattern" },
                patterns = { ".git", "Makefile", "package.json" },
                silent_chdir = false,
            })
            -- Telescope integration
            local ok, telescope = pcall(require, "telescope")
            if ok then
                telescope.load_extension("projects")
            end
        end,
    },

    -- noice.nvim - Better UI for messages, cmdline, popupmenu
    {
        "folke/noice.nvim",
        enabled = false, -- disabled by default, set to true to enable
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = true,
            },
        },
        keys = {
            { "<leader>nl", "<cmd>Noice last<cr>",    desc = "Noice last message" },
            { "<leader>nh", "<cmd>Noice history<cr>", desc = "Noice history" },
            { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss notifications" },
        },
    },

    -- lualine - Statusline
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "gruvbox",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },

    -- alpha-nvim - Splash screen
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
                "                                                     ",
            }

            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
                dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
                dashboard.button("p", "  Projects", ":Telescope projects<CR>"),
                dashboard.button("g", "  Grep text", ":Telescope live_grep<CR>"),
                dashboard.button("c", "  Config", ":e ~/.config/nvim/<CR>"),
                dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
                dashboard.button("q", "  Quit", ":qa<CR>"),
            }

            dashboard.section.footer.val = "kolbbond"

            alpha.setup(dashboard.opts)
        end,
    },

    -- bufferline - Tab bar for buffers
    {
        "akinsho/bufferline.nvim",
        enabled = false,
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",   desc = "Prev buffer" },
            { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",   desc = "Next buffer" },
            { "<leader>bp", "<cmd>BufferLinePick<cr>",        desc = "Pick buffer" },
            { "<leader>bc", "<cmd>BufferLinePickClose<cr>",   desc = "Pick close buffer" },
            { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
            { "<leader>bd", "<cmd>bdelete<cr>",               desc = "Close current buffer" },
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "netrw",
                callback = function()
                    vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { buffer = true, desc = "Prev buffer" })
                    vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { buffer = true, desc = "Next buffer" })
                end,
            })
        end,
        opts = {
            options = {
                diagnostics = "nvim_lsp",
                always_show_bufferline = true,
                offsets = {
                    { filetype = "neo-tree", text = "Files", highlight = "Directory" },
                },
            },
            highlights = {
                buffer_selected = { italic = false },
                diagnostic_selected = { italic = false },
                hint_selected = { italic = false },
                hint_diagnostic_selected = { italic = false },
                info_selected = { italic = false },
                info_diagnostic_selected = { italic = false },
                warning_selected = { italic = false },
                warning_diagnostic_selected = { italic = false },
                error_selected = { italic = false },
                error_diagnostic_selected = { italic = false },
            },
        },
    },

    -- mini.animate - Smooth animations
    {
        "echasnovski/mini.animate",
        event = "VeryLazy",
        opts = {
            cursor = { timing = function(_, n) return 150 / n end },
            scroll = { enable = false },
            resize = { enable = false },
            open = { enable = false },
            close = { enable = false },
        },
    },

    -- mini.map - Minimap sidebar
    {
        "echasnovski/mini.map",
        keys = {
            { "<leader>mm", function() require("mini.map").toggle() end, desc = "Toggle minimap" },
        },
        config = function()
            local map = require("mini.map")
            map.setup({
                symbols = {
                    encode = map.gen_encode_symbols.dot("4x2"),
                },
                window = {
                    width = 10,
                    winblend = 50,
                },
            })
        end,
    },

    -- Aerial - Code outline sidebar
    {
        "stevearc/aerial.nvim",
        enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            layout = {
                min_width = 30,
            },
            filter_kind = false,
        },
    },
}
