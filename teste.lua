<<<<<<< HEAD
local files = io.popen([[rg '^#\+[a-zA-Z1-9 ]+:.*' -m 1]])
local filesread = files:read("*a")
files:close()
local seila = {}
for item in string.gmatch(filesread, "[^\n]+") do
    local file = string.match(item, "(.+#%+TAGS+):.*")
    local metadata = string.match(item, "%g+:<!%-%- #(.+) %-%->")
    print(file)
end
