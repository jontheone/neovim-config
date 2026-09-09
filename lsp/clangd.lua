return {
    -- root_dir = lspconfig.util.root_pattern(".clangd", "compile_commands.json", ".git", "compile_flags.txt"),
    -- init_options = {
    --     fallbackFlags = {
    --       "-isystem", "C:/msys64/ucrt64/include",
    --       "-isystem", "C:/msys64/mingw64/include",
    -- },
    cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--query-driver=C:/msys64/ucrt64/bin/g++.exe",
  },
  filetype = {
      'c',  'cpp', 'h', 'hpp'
  }
}
