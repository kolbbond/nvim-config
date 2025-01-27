local dap, dapui = require('dap'), require("dapui");


-- adapters

-- gdb for c/c++
dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    --outputMode = "remote",
    console = "integratedTerminal"

}

dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = "/home/" ..
    os.getenv("USER") .. '/.vscode/extensions/ms-vscode.cpptools-1.22.11-linux-x64/debugAdapters/bin/OpenDebugAD7',
}

dap.adapters.codelldb = {
    type = 'server',
    host = '127.0.0.1',
    port = 13000,
    executable = {
        -- CHANGE THIS to your path!
        command = 'codelldb',
        args = { "--port", "${port}" },
    }
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

-- print icons support
--[[
require("lazydev").setup({
    library = { "nvim-dap-ui" },
})
--]]

-- configs
dap.configurations.cpp = {
    {
        name = "Launch cppdbg",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
    },
    {
        name = "Launch gdb",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
        console = "integratedTerminal",
    },
    {
        -- @hey: move this to a json loader
        name = "Launch vvavviz ",
        type = "gdb",
        request = "launch",
        program = "build/vvavviz",
        args = "../../assets/all_wavs/ex23.wav",
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
    {
        name = "Launch Script",
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
    {
        name = "C++ Debug And Run",
        type = "codelldb",
        request = "launch",
        program = function()
            -- First, check if exists CMakeLists.txt
            local cwd = vim.fn.getcwd()
            if file.exists(cwd, "CMakeLists.txt") then
                -- Then invoke cmake commands
                -- Then ask user to provide execute file
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            else
                local fileName = vim.fn.expand("%:t:r")
                -- create this directory
                os.execute("mkdir -p " .. "bin")
                local cmd = "!g++ -g % -o bin/" .. fileName
                -- First, compile it
                vim.cmd(cmd)
                -- Then, return it
                return "${fileDirname}/bin/" .. fileName
            end
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        runInTerminal = true,
        console = "integratedTerminal",
    },
}

require('nvim-dap-virtual-text').setup {
    --    dap_virtual_text_status.setup({
    enabled = true,                        -- enable this plugin (the default)
    enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    show_stop_reason = true,               -- show stop reason when stopped for exceptions
    commented = true,                      -- prefix virtual text with comment string
    only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
    all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
    filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
    -- experimental features:
    virt_text_pos = "eol",                 -- position of virtual text, see `:h nvim_buf_set_extmark()`
    all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
    virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
    -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
}



-- keymaps
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint);
vim.keymap.set("n", "<leader>gb", dap.run_to_cursor);
vim.keymap.set("n", "<leader>dc", dap.continue);

-- eval under cursor
vim.keymap.set("n", "<leader>?", function()
    require("dapui").eval(nil, { enter = true })
end);


-- dap ui
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end

dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end

dap.listeners.before.event_terminated.dapui_config = function()
    --dapui.close()
end

dap.listeners.before.event_exited.dapui_config = function()
    --    dapui.close()
end

dapui.setup({

    layouts = {
        -- Changing the layout order will give more space to the first element
        {
            -- You can change the order of elements in the sidebar
            elements = {
                { id = "scopes",      size = 0.25, },
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
            size = 20,
            position = 'bottom', -- Can be "bottom" or "top"
        },
    },
    controls = {
        icons = {
            pause = '',
            play = ' (F1)',
            step_into = ' (F2)',
            step_over = ' (F3)',
            step_out = ' (F4)',
            step_back = ' (F5)',
            run_last = ' (F10)',
            restart = "R (F11)",
            terminate = ' (F11)',
            disconnect = ' ([l]d)',
        },
    },
})

--[[
require("neodev").setup({
    library = { plugins = { "nvim-dap-ui" }, types = true },
    console = "integratedTerminal"
})
--]]


-- keymaps
vim.keymap.set("n", "<F1>", dap.continue);
vim.keymap.set("n", "<F2>", dap.step_into);
vim.keymap.set("n", "<F3>", dap.step_over);
vim.keymap.set("n", "<F4>", dap.step_out);
vim.keymap.set("n", "<F5>", dap.step_back);
vim.keymap.set("n", "<F11>", dap.restart);

vim.keymap.set("n", "<leader>dut", dapui.toggle);
vim.keymap.set("n", "<leader>de", dapui.eval);
vim.keymap.set("n", "<leader>dt",
    function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").threads) end);
-- exception handling
--dap.defaults.cpp.exception_breakpoints = { "Notice", "Warning", "Error", "Exception" }

--dap.set_exception_breakpoints({"raised", "uncaught"})

dap.defaults.fallback.exception_breakpoints = { 'raised', 'uncaught' }
dap.defaults.fallback.auto_continue_if_many_stopped = false;

require("lazydev").setup({
    library = { "nvim-dap-ui" },
})

--[[
-- neotest
require("neotest").setup({
    adapters = {
        require("neotest-python")({
            dap = { justMyCode = false },
        }),
        require("neotest-plenary"),
        require("neotest-vim-test")({
            ignore_file_types = { "python", "vim", "lua" },
        }),
    },
})
--]]

--[[
dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
end

dap.listeners.before.event_terminated['dapui_config'] = function(e)
    require('dap.utils').info(
        string.format(
            "program '%s' was terminated.",
            vim.fn.fnamemodify(e.config.program, ':t')
        )
    )
    dapui.close()
end
]]
