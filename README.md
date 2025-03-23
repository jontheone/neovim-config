# Dependencies
1. ripgrep
2. the clang compiler from llvm(gcc is bugged with treesitter)
3. also install gcc cause its a better compiler and needed to build some tools
4. install the libraries from visual studio c++ in order to compile the lsp correctly



# deprecated step

do this only if you want to use telescope as picker

The next step is to use fzf engine in telescope

1. install make
    a. you'll have to build the fzf extension for telescope yourself
    b. just enter the directory:
        i. from you neovim config
        ii. cd ../nvim-data/lazy/telescope-fzf-native.nvim/
    c. run ´´´make´´´
