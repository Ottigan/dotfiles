return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        { "mason-org/mason.nvim", opts = {} },
        "jay-babu/mason-nvim-dap.nvim",
        "leoluz/nvim-dap-go",
        -- Inline variable values as virtual text while stepping
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {
                highlight_changed_variables = true,
                highlight_new_as_changed = true,
                show_stop_reason = true,
                virt_text_pos = "eol",
            },
        },
    },
    keys = {
        {
            "<F1>",
            function()
                require("dap").continue()
            end,
            desc = "[C]ontinue",
        },
        {
            "<F2>",
            function()
                require("dap").step_into()
            end,
            desc = "Step into",
        },
        {
            "<F3>",
            function()
                require("dap").step_over()
            end,
            desc = "Step over",
        },
        {
            "<F4>",
            function()
                require("dap").step_out()
            end,
            desc = "Step out",
        },
        {
            "<F5>",
            function()
                require("dap").step_back()
            end,
            desc = "Step back",
        },
        {
            "<F6>",
            function()
                require("dap").restart()
            end,
            desc = "Restart",
        },
        {
            "<F7>",
            function()
                require("dapui").toggle()
            end,
            desc = "Toggle UI",
        },
        {
            "<leader>db",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Toggle [b]reakpoint",
        },
        {
            "<leader>dB",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "Set conditional [B]reakpoint",
        },
        {
            "<leader>dc",
            function()
                require("dap").clear_breakpoints()
            end,
            desc = "[C]lear",
        },
        {
            "<leader>dh",
            function()
                require("dap.ui.widgets").hover()
            end,
            desc = "[H]over value",
        },
        {
            "<leader>dl",
            function()
                require("dap").run_last()
            end,
            desc = "Run [l]ast",
        },
        {
            "<leader>de",
            function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.expression)
            end,
            desc = "[E]valuate expression",
        },
        {
            "<leader>df",
            function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.frames)
            end,
            desc = "Stack [f]rames",
        },
        {
            "<leader>ds",
            function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.scopes)
            end,
            desc = "[S]copes",
        },
        {
            "<leader>dt",
            function()
                require("dap").terminate()
            end,
            desc = "[T]erminate",
        },
    },
    config = function()
        local dap = require("dap")

        require("mason-nvim-dap").setup({
            automatic_installation = true,
            handlers = {},
            ensure_installed = {
                "delve",
                "js",
            },
        })

        -- JAVASCRIPT/TYPESCRIPT ──────────────────────────────────────
        dap.adapters["pwa-node"] = {
            type = "server",
            host = "::1",
            port = "${port}",
            executable = {
                command = "js-debug-adapter",
                args = { "${port}" },
            },
        }

        -- GO ─────────────────────────────────────────────────────────
        require("dap-go").setup()

        -- DAP UI ─────────────────────────────────────────────────────
        local dapui = require("dapui")
        dapui.setup()

        -- Change breakpoint icons
        vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
        vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
        local breakpoint_icons = {
            Breakpoint = "●",
            BreakpointCondition = "⊜",
            BreakpointRejected = "⊘",
            LogPoint = "◆",
            Stopped = "⭔",
        }

        for type, icon in pairs(breakpoint_icons) do
            local tp = "Dap" .. type
            local hl = (type == "Stopped") and "DapStop" or "DapBreak"
            vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
        end

        dap.listeners.before.attach.dapui_config = function()
            vim.schedule(dapui.open)
        end
        dap.listeners.before.launch.dapui_config = function()
            vim.schedule(dapui.open)
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end,
}
