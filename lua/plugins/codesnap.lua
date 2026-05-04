return {
    {
        "mistricky/codesnap.nvim",
        build = "make",
        cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapASCII", "CodeSnapHighlight", "CodeSnapSaveHighlight" },
        opts = {
            save_path = "~/Downloads",
            watermark = "",
        }
    },
}
