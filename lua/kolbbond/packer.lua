-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.6',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    -- fzf (telescope alternative?)
    --[[
use { "ibhagwan/fzf-lua",
  -- optional for icon support
  requires = { "nvim-tree/nvim-web-devicons" }
  }
  --]]

    --[[ THEMES --]]

    -- colorizer

    use("norcalli/nvim-colorizer.lua");

    -- colorbudy
    use("tjdevries/colorbuddy.nvim")

    -- github
    use("projekt0n/github-nvim-theme");

    -- rose pine theme
    use("rose-pine/neovim");

    -- lush
    use("rktjmp/lush.nvim");

    -- gruvbox
    use("ellisonleao/gruvbox.nvim");
    --use("sainnhe/gruvbox-material.nvim");
    use("luisiacc/gruvbox-baby");

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

    ------------------------------------------------------
    -- End of themes

    -- treesitter
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })

    -- playground
    use('nvim-treesitter/playground')

    -- harpoon
    use "nvim-lua/plenary.nvim" -- don't forget to add this one if you don't have it yet!
    use {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        requires = { { "nvim-lua/plenary.nvim" } }
    }

    -- undotree
    use('mbbill/undotree');
    use('tpope/vim-fugitive');

    -- sniprun
    use { 'michaelb/sniprun', run = 'sh./install.sh' };

    -- lsp - zero
    use {
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
    }

    -- prettier
    use('neovim/nvim-lspconfig')
    use('jose-elias-alvarez/null-ls.nvim')
    use('MunifTanjim/prettier.nvim')

    -- vimbegood
    use("ThePrimeagen/vim-be-good");

    -- suda
    use('lambdalisue/suda.vim')

    -- matlab???
    --use("daeyun/vim-matlab");
    use("kolbbond/nvim-matlab"); -- github version

    -- slime (for python repl etc.)
    use("jpalardy/vim-slime");

    -- dev 
     --use ('~/.config/nvim/plugin/nvim-matlab.nvim')
    -- use ('~/.config/nvim/plugin/cheddar.nvim')

    -- iron (REPL)
    use('Vigemus/iron.nvim')

    -- dev
    use('~/.config/nvim/plugin/nvim-matlab.nvim')
    -- use ('~/.config/nvim/plugin/cheddar.nvim')
end)
