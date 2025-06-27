local M = {}

M.render = function()
    local filename = vim.fn.expand("%:p")
    local wiki_root = vim.g.wiki_root
    if not (filename:sub(-3) == ".md") then
        print("This is not a markdown file bucko")
        return
    end
    if not (os.execute(string.format('[ -f "%s" ]', filename)) == 0) then
        print("invalid path bucko")
        return
    end
    local pdfname = vim.fs.abspath(vim.fs.joinpath(wiki_root, "pdfs", string.format("%s.pdf", filename:match(".+/(.+).md"))))
    if os.execute(string.format('[ -f "%s" ]', pdfname)) == 0 then
        local input = vim.fn.input("There is already a pdf for this file do you wish to recompile (y/n)")
        if input:match("^%s*(.-)%s*$") == "y" then
            if os.execute(string.format([[pandoc %s -o %s]], filename, pdfname)) == 0 then
                os.execute(string.format('zathura %s &', pdfname))
            else
                print("could not transformt the file into pdf")
            end
        else
            os.execute(string.format('zathura %s &', pdfname))
        end
    end
end

return M
