local dap = require('dap');

require("neodev").setup({
    library = { plugins = { "nvim-dap-ui" }, types = true },
    ...
})

local ui = require('dapui').setup();
require('nvim-dap-virtual-text').setup {

    --
}

-- gdb for c/c++
dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}

-- python setup
require("dap-python").setup(os.getenv("HOME") .. ".virtualenvs/debugpy/bin/python -m debugpy");

-- lua
dap.adapters["local-lua"] = {
    type = "executable",
    command = "node",
    args = {
        (os.getenv("HOME") .. "build/local-lua-debugger-vscode/extension/debugAdapter.js")
    },
    enrich_config = function(config, on_config)
        if not config["extensionPath"] then
            local c = vim.deepcopy(config)
            -- 💀 If this is missing or wrong you'll see
            -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
            c.extensionPath = (os.getenv("HOME") .. "build/local-lua-debugger-vscode/");
            on_config(c)
        else
            on_config(config)
        end
    end,
}

dap.configurations.c = {
    {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
    {
        name = "Select and attach to process",
        type = "gdb",
        request = "attach",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        pid = function()
            local name = vim.fn.input('Executable name (filter): ')
            return require("dap.utils").pick_process({ filter = name })
        end,
        cwd = '${workspaceFolder}'
    },
    {
        name = 'Attach to gdbserver :1234',
        type = 'gdb',
        request = 'attach',
        target = 'localhost:1234',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}'
    },
}


-- keymaps
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint);
vim.keymap.set("n", "<leader>gb", dap.run_to_cursor);

-- eval under cursor
vim.keymap.set("n", "<leader>?", function()
    require("dapui").eval(nil, { enter = true })
end

);

-- check install
local ok, ui = pcall(require, 'dapui')
if not ok then
    return
end

ui.setup({
    layouts = {
        -- Changing the layout order will give more space to the first element
        {
            -- You can change the order of elements in the sidebar
            elements = {
                -- { id = "scopes", size = 0.25, },
                { id = 'stacks',      size = 0.50 },
                { id = 'breakpoints', size = 0.25 },
                { id = 'watches',     size = 0.25 },
            },
            size = 56,
            position = 'right', -- Can be "left" or "right"
        },
        {
            elements = {
                { id = 'repl',    size = 0.60 },
                { id = 'console', size = 0.40 },
            },
            size = 8,
            position = 'bottom', -- Can be "bottom" or "top"
        },
    },
    controls = {
        icons = {
            pause = '',
            play = ' (F5)',
            step_into = ' (F6)',
            step_over = ' (F7)',
            step_out = ' (F8)',
            step_back = ' (F9)',
            run_last = ' (F10)',
            terminate = ' (F12)',
            disconnect = ' ([l]d)',
        },
    },
})

local dap = require('dap')

dap.listeners.after.event_initialized['dapui_config'] = function()
    ui.open()
end

dap.listeners.before.event_terminated['dapui_config'] = function(e)
    require('utils').info(
        string.format(
            "program '%s' was terminated.",
            vim.fn.fnamemodify(e.config.program, ':t')
        )
    )
    ui.close()
end

-- dap ui
dap.listeners.before.attach.dapui_config = function()
    ui.open()
end

dap.listeners.before.launch.dapui_config = function()
    ui.open()
end

dap.listeners.before.event_terminated.dapui_config = function()
    ui.close()
end

dap.listeners.before.event_exited.dapui_config = function()
    ui.close()
end
