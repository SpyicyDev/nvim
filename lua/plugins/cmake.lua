return {
    "Civitasv/cmake-tools.nvim",
    dependencies = {
        {
            "akinsho/toggleterm.nvim",
            opts = {
            },
        },
    },
    opts = {
        cmake_executor = {
            name = "toggleterm",
            opts = {
                direction = "float",
                close_on_exit = true,
                auto_scroll = true,
                singleton = true,
            },
        },
        cmake_runner = {
            name = "toggleterm",
            opts = {
                direction = "float",
                close_on_exit = false,
                auto_scroll = true,
                singleton = true,
            },
        },
        cmake_notifications = {
            runner = { enabled = false },
        },
    },
}
