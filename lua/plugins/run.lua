return {
    {
        "spyicydev/run.nvim",
        dependencies = {
            "numToStr/FTerm.nvim",
        },
        opts = {
            filetype = {
                scala = function ()
                    vim.notify("Execute 'sbt run' in a separate tmux window!")
                end,
                python = function()
                    if vim.fn.findfile("pyproject.toml", ".;") ~= "" then
                        return "poetry run python3 %f"
                    else
                        return "python3 %f"
                    end
                end,
                rust = "cargo run",
                lua = "lua %f",
                markdown = ":MarkdownPreview",
                java = function()
                    if vim.fn.findfile("build.gradle", ".;") ~= "" then
                        return "./gradlew run"
                    else
                        return "java %f"
                    end
                end,
                r = "rscript %f",
            },
        },
    }
}
