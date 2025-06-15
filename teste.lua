local seila = {
    { label = "teste2", p = 2},
    { label = "teste4", p = 4},
    { label = "teste1", p = 1},
    { label = "teste3", p = 2},
}
table.sort(seila, function(a, b)
    return a.p < b.p
end)
print(vim.inspect(seila))
