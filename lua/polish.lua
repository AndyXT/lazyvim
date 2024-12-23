-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }
vim.cmd [[" set
autocmd TermEnter term://*toggleterm#*
      \ tnoremap <silent><M-i> <Cmd>exe v:count1 . "ToggleTerm"<CR>

" By applying the mappings this way you can pass a count to your
" mapping to open a specific window.
" For example: 2<M-i> will open terminal 2
nnoremap <silent><M-i> <Cmd>exe v:count1 . "ToggleTerm"<CR>
inoremap <silent><M-i> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>
tnoremap <silent><M-i> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>
]]
