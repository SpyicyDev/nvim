return {
    {
        "spyicydev/run.nvim",
        dependencies = {
            "numToStr/FTerm.nvim",
        },
        opts = {
            filetype = {
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
                ocaml = function ()
                    -- find the main executable module name from the dune file in the bin directory
                    local dune_file = vim.fn.findfile("dune", ".;")
                    local dune_file_content = io.open(dune_file):read("*a")


                    return "dune exec " .. module_name

                end,
            },
        },
    }
}
