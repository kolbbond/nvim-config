-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- packer is unmaintained but it works well
-- might switch to lazy later idk

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use('wbthomason/packer.nvim')

    --------------------------------------------------
    -- super useful section
    -- telescope
    -- fuzzy finder for files
    use({
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    });

    -- treesitter
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })

    -- playground
    use('nvim-treesitter/playground')

    -- highlight todo
    use("folke/todo-comments.nvim");

    -- color different delimiters
    use("HiPhish/rainbow-delimiters.nvim");

    -- harpoon
    -- allows quick movement between files from a hotlist
    use("nvim-lua/plenary.nvim") -- don't forget to add this one if you don't have it yet!
    use({
        "kolbbond/harpoon2",
        branch = "master",
        requires = { { "nvim-lua/plenary.nvim" } }
    });

    -- undotree
    -- keeps a huge list of changes
    -- @hey, investigate
    use('mbbill/undotree');

    -- fugitive
    -- @hey, start using this
    use('tpope/vim-fugitive');

    -- edit directories
    -- we might just prefer netrw?
    use({ "stevearc/oil.nvim" });

    -- show hotkeys
    use("folke/which-key.nvim")

    -- lsp - zero
    -- head lsp, super useful
    use({
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            --- Uncomment the two plugins below if you want to manage the language servers from neovim
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- LSP Support
            { 'neovim/nvim-lspconfig' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'L3MON4D3/LuaSnip' },
        }
    });

    use({"folke/lazydev.nvim"});

    -- debugging
    use({
        "mfussenegger/nvim-dap",
        requires =
        { "rcarriga/nvim-dap-ui" },
        { "nvim-neotest/nvim-nio" },
        { "theHamsta/nvim-dap-virtual-text" },
        { "SGauvin/ctest-telescope.nvim" },
        { "mfussenegger/nvim-dap-python" },
    });

    --use({ "SGauvin/ctest-telescope.nvim" });
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "alfaix/neotest-gtest",
        }
    }

    -- cmake
    use('Civitasv/cmake-tools.nvim');

    -- C++ clangd
    use('p00f/clangd_extensions.nvim');

    -- Autocompletion on command line
    use('hrsh7th/cmp-cmdline');

    -- dap-ui separate
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } }
    use('folke/neodev.nvim');

    -- diagnostics
    use("folke/trouble.nvim");

    use({ "artemave/workspace-diagnostics.nvim" })

    -- suda
    -- allows writing to files that required elevated permissions
    use('lambdalisue/suda.vim')

    -- like tmux but also use tmux
    use { "akinsho/toggleterm.nvim", tag = '*', config = function()
        require("toggleterm").setup()
    end }
    --------------------------------------------------
    -- REPLS

    -- matlab
    use("kolbbond/nvim-matlab"); -- github version
    -- iron (REPL)
    -- for python and octave atm
    use('Vigemus/iron.nvim')

    -- sniprun
    --    use { 'michaelb/sniprun', run = 'sh./install.sh' };

    -- slime (for python repl etc.)
    -- seems that iron might work better for us
    --    use("jpalardy/vim-slime");
    --------------------------------------------------


    -- dev
    --use('~/.config/nvim/plugin/nvim-matlab.nvim')
    -- use ('~/.config/nvim/plugin/cheddar.nvim')

    -- vimbegood
    -- fun games
    --use("kolbbond/vim-be-good");
    --use('~/.config/nvim/plugin/vim-be-good');

    -- prettier
    use('neovim/nvim-lspconfig')
    use('jose-elias-alvarez/null-ls.nvim')
    use('MunifTanjim/prettier.nvim')

    --------------------------------------------------
    --[[ THEMES --]]

    -- colorizer

    -- gruvbox
    -- objectively the best so we forked it
    use("kolbbond/gruvbox.nvim");

    -- gruvbox alts
    use("luisiacc/gruvbox-baby");
    use("sainnhe/gruvbox-material");

    -- rose pine theme
    use("rose-pine/neovim");

    use("norcalli/nvim-colorizer.lua");

    -- colorbuddy
    use("tjdevries/colorbuddy.nvim")

    -- github
    use("projekt0n/github-nvim-theme");

    -- lush
    use("rktjmp/lush.nvim");


    -- tokyonight
    use("folke/tokyonight.nvim");

    -- modus-themes
    use("miikanissi/modus-themes.nvim");

    -- nord
    use("gbprod/nord.nvim");

    -- vscode
    use("Mofiqul/vscode.nvim");

    --- kanagawa theme
    use("rebelot/kanagawa.nvim")

    -- flow
    use("0xstepit/flow.nvim");

    -- rasmus
    use('kvrohit/rasmus.nvim')

    -- darkvoid
    use('aliqyan-21/darkvoid.nvim');

    -- falcon
    use("fenetikm/falcon")

    -- miasma, like gruvbox but dirtier
    use('xero/miasma.nvim');

    -- fluoromachine (neon)
    use('maxmx03/fluoromachine.nvim')

    --  moonlight (more neon)
    use('shaunsingh/moonlight.nvim');


    ------------------------------------------------------
    -- End of themes

    -- icons and symbols
    use('nvim-telescope/telescope-symbols.nvim');
    use("stevearc/dressing.nvim");
    use('nvim-tree/nvim-web-devicons')
end)
