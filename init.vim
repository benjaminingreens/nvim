" ==========================================================================
" BENJAMIN'S COMBINED INIT.VIM FOR NEOVIM
" ========================================================================== 

" ==========================================================================
" THINGS TO ADD (Future Enhancements)
" ========================================================================== 
" - Fix end and start of line symbols so they are invisible or something more
"   agreeable
" - Change cursor appearance when in insert mode
" - Python formatter, like Black
" - Cursor position when scrolling needs to be constant, or have it disappear
" - When using find, show number of items found
" - When using find, stop highlighting when finished using
" - Fix folding for markdown (no folding)
" - Set a custom foldmethod for when folds are needed in files where there is
"   no syntax or indent folding
" - Make no folds the default setting
" - Actual auto-correction for spelling
" - Vim align plugin? looks cool
" - Wrapping on for markdown and csv only?
" - Better markdown linting signs? Don't like the current ones
" - When entering insert mode, last line goes blank for a moment
" - Can't get black formatter to work for python
" - Set column for formatting at around 79
" - When leaving Goyo in markdown, spell highlighting changes to different
"   format
" - Seems like my diagnostics for c are coming from two different places
" - My python diagnostics don't show up in the message area as they do with
"   markdown and C
" - Gitsigns transparency
" - Other theme configs
" - Colours of status bars for text

" ==========================================================================
" Basic Setup
" ========================================================================== 

" Set leader key
let mapleader = " "

syntax off
" set laststatus=2
set laststatus=0
" set cmdheight=1
set cmdheight=0
set noshowmode
set nowrap
set termguicolors
set number
set relativenumber
set ignorecase
set smartcase
set showmatch
set hlsearch
set wildmenu
set smoothscroll
set display+=lastline
set fillchars=lastline:.
set fillchars=eob:\ 
set signcolumn=yes
" set colorcolumn=80
filetype plugin indent on

" ============================================================================
" Filetype Specific Settings
" ============================================================================

" Python Settings
autocmd FileType python setlocal foldmethod=indent
autocmd FileType python setlocal nofoldenable
autocmd FileType python nnoremap <leader>f :setlocal foldenable!<CR>

" Markdown Settings
autocmd FileType markdown setlocal wrap
autocmd FileType markdown setlocal linebreak
autocmd FileType markdown setlocal nofoldenable
autocmd FileType markdown setlocal virtualedit=all
autocmd FileType markdown setlocal spell spelllang=en_gb
autocmd FileType markdown setlocal colorcolumn=
autocmd FileType csv setlocal colorcolumn=

" Spell Highlights for Markdown
augroup SpellCheckHighlight
  autocmd!
  " Apply custom spell highlights only for markdown files
  autocmd FileType markdown highlight SpellBad guifg=#E06C75 ctermfg=LightRed gui=bold cterm=bold
  autocmd FileType markdown highlight SpellCap guifg=#E5C07B ctermfg=LightYellow gui=bold cterm=bold
  autocmd FileType markdown highlight SpellRare guifg=#61AFEF ctermfg=LightBlue gui=bold cterm=bold
  autocmd FileType markdown highlight SpellLocal guifg=#98C379 ctermfg=LightGreen gui=bold cterm=bold
augroup END

" Key Mappings for Markdown Wrapping Navigation
autocmd FileType markdown nnoremap j gj
autocmd FileType markdown nnoremap k gk
autocmd FileType markdown nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
autocmd FileType markdown nnoremap <expr> j v:count == 0 ? 'gj' : 'j'

" Markdown Preview Browser
let g:vim_markdown_preview_browser = 'qutebrowser'

" Limelight Settings for Markdown
autocmd FileType markdown let g:limelight_bop = '^.*$'
autocmd FileType markdown let g:limelight_eop = '\n'
autocmd FileType markdown let g:limelight_paragraph_span = 0

" Ensure Terminal Directory in Neovim Matches Last Active Buffer
lua << EOF
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        vim.cmd("lcd " .. vim.fn.expand("%:p:h"))
    end,
})
EOF

autocmd BufRead,BufNewFile *.Rmd set filetype=rmd

" ==========================================================================
" Plugin Manager (packer.nvim) and Plugins
" ==========================================================================
" Bootstrap packer
lua << EOF
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
ensure_packer()
EOF

" Load packer explicitly
packadd packer.nvim

" Use packer to manage plugins
lua << EOF
require('packer').startup(function(use)
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'wbthomason/packer.nvim'

  -- Plugins from original vimrc
  use 'preservim/vim-markdown'
  use 'JamshedVesuna/vim-markdown-preview'
  use 'mechatroner/rainbow_csv'
  use { 'catppuccin/nvim', as = 'catppuccin' }
  use 'junegunn/goyo.vim'
  use 'junegunn/limelight.vim'
  use 'sheerun/vim-polyglot'
  use 'psf/black'

  -- Additional Plugins for Neovim
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'frabjous/knap'
  use 'dense-analysis/ale'

  use 'nvim-lua/plenary.nvim'
  -- Above is a dependency for below
  use 'lewis6991/gitsigns.nvim'
  use { 'rose-pine/neovim', as = 'rose-pine' }
  use { "savq/melange-nvim", as = 'melange' }
  use { "sho-87/kanagawa-paper.nvim", as = 'kanagawa-paper' }
  use { 'morhetz/gruvbox', as = 'gruvbox' }
  use {"adisen99/codeschool.nvim", requires = {"rktjmp/lush.nvim"}}
  use { "ramojus/mellifluous.nvim" }

end)
EOF

lua <<EOF
require('gitsigns').setup {
    signs = {
        add          = { text = '│' },  -- Customize the symbol for added lines
        change       = { text = '│' },  -- Customize the symbol for changed lines
        delete       = { text = '_' },  -- Customize the symbol for deleted lines
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
    },
    signcolumn = true,  -- Enable sign column
    numhl      = false, -- Disable line number highlighting
    linehl     = false, -- Disable line highlighting
    word_diff  = false, -- Disable word diff
}
EOF

" ==========================================================================
" LSP and Treesitter Configuration
" ==========================================================================
lua << EOF
-- General LSP Setup
require'nvim-treesitter.configs'.setup {
    ensure_installed = {"python", "c"},
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

-- CCLS Configuration
require'lspconfig'.ccls.setup{
    init_options = {
        cache = {
            directory = ".ccls-cache";
        };
    },
    on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local opts = { noremap=true, silent=true }

        -- Keybindings for LSP Functionality (C/C++)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    end,
}

-- Pyright Configuration
require'lspconfig'.pyright.setup{
    on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local opts = { noremap=true, silent=true }

        -- Keybindings for LSP Functionality (Python)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    end,
}

-- Diagnostics Configuration
vim.diagnostic.config({
  virtual_text = false,  -- Disables in-line virtual text
  float = {
    source = "always",  -- Show the source in the floating window
  },
})
EOF

" ==========================================================================
" ALE Configuration
" ==========================================================================
" Enable ALE for Markdown
let g:ale_linters = {
    \ 'markdown': ['markdownlint'],
    \ }

" Set the path for the temporary markdownlint config file
let temp_config = "/tmp/markdownlint_config.json"

" Create the JSON configuration for markdownlint
call writefile([
    \ '{',
    \ '  "MD013": false',
    \ '}'
    \ ], temp_config)

" Enable linting when opening, saving, or editing files
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 'always'
let g:ale_virtualtext_cursor = 0
" Configure ALE to use the temporary markdownlint config file
let g:ale_markdown_markdownlint_options = '--config ' . temp_config

" ==========================================================================
" Key Mappings
" ==========================================================================
" Diagnostics Float Window
nnoremap <silent> <leader>e :lua vim.diagnostic.open_float(nil, {focus=false})<CR>

" Navigate Diagnostics
nnoremap <silent> [d :lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d :lua vim.diagnostic.goto_next()<CR>

" Python Formatter (Black)
nnoremap <leader>bf :Black<CR>

" Clipboard settings
nnoremap <leader>y "+y
vnoremap <leader>y "+y

" ==========================================================================
" Plugin Specific Configurations
" ==========================================================================
" Goyo Settings
autocmd! User GoyoEnter nested call EnterGoyo()
autocmd! User GoyoLeave nested call LeaveGoyo()
let g:goyo_width = '60%'

" Limelight Settings
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

" Function to Set Transparent Background
function! LeaveGoyo()
    highlight Normal ctermbg=NONE guibg=NONE
    highlight NonText ctermbg=NONE guibg=NONE
    highlight LineNr ctermbg=NONE guibg=NONE
    highlight SignColumn ctermbg=NONE guibg=NONE
    highlight EndOfBuffer ctermbg=NONE guibg=NONE
    highlight NormalNC guibg=NONE ctermbg=NONE
    " Set the status line colors to match tmux settings (Kanagawa theme)
    highlight StatusLine guibg=#2a2a37 guifg=#8888aa
    highlight StatusLineNC guibg=#2a2a37 guifg=#5c5c6a " Dim the inactive lines slightly
    highlight MsgArea guifg=#8888aa
    highlight Cmdline guifg=#8888aa
    highlight CmdlinePrompt guifg=#8888aa
    exec 'Limelight!'

    " Spell Highlights for Markdown
    augroup SpellCheckHighlight
      autocmd!
      " Apply custom spell highlights only for markdown files
      autocmd FileType markdown highlight SpellBad guifg=#E06C75 ctermfg=LightRed gui=bold cterm=bold
      autocmd FileType markdown highlight SpellCap guifg=#E5C07B ctermfg=LightYellow gui=bold cterm=bold
      autocmd FileType markdown highlight SpellRare guifg=#61AFEF ctermfg=LightBlue gui=bold cterm=bold
      autocmd FileType markdown highlight SpellLocal guifg=#98C379 ctermfg=LightGreen gui=bold cterm=bold
    augroup END

endfunction

" Function to set non-active area as transparent when in Goyo
function! EnterGoyo()
    highlight NormalNC guibg=NONE ctermbg=NONE
    exec 'Limelight'
endfunction

" ==========================================================================
" Appearance Configurations
" ==========================================================================
lua <<EOF
vim.cmd([[colorscheme mellifluous]])
EOF

highlight Normal ctermbg=NONE guibg=NONE
highlight NonText ctermbg=NONE guibg=NONE
highlight LineNr ctermbg=NONE guibg=NONE
highlight SignColumn ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE
highlight NormalNC guibg=NONE ctermbg=NONE
" Set the status line colors to match tmux settings (Kanagawa theme)
highlight StatusLine guibg=#2a2a37 guifg=#8888aa
highlight StatusLineNC guibg=#2a2a37 guifg=#5c5c6a " Dim the inactive lines slightly
highlight MsgArea guifg=#8888aa
highlight Cmdline guifg=#8888aa
highlight CmdlinePrompt guifg=#8888aa
autocmd ColorScheme * highlight SignColumn ctermbg=NONE guibg=NONE

" ==========================================================================
" Completion Configuration
" ==========================================================================
lua << EOF
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    -- Remap <Tab> and <S-Tab> for cycling
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback() -- Fall back to original tab behavior
      end
    end, { "i", "s" }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  })
})
EOF

" ==========================================================================
" LaTeX settings: Quite broken at present
" ==========================================================================
lua << EOF
vim.g.knap_settings = {

    texoutputext = "pdf",
    textopdf = "pdflatex -interaction=nonstopmode -synctex=1 %docroot%",
    textopdfviewerlaunch = "sioyek %outputfile%",
    textopdfviewerrefresh = "sioyek --reuse-instance %outputfile%",
    textopdfforwardjump = nil,  -- Update this if SyncTeX is needed and supported by your viewer
    textopdfshorterror = "A=%outputfile% ; LOGFILE=\"${A%.pdf}.log\"",

    -- Markdown settings
    mdoutputext = "html",
    mdtopdf = nil,
    mdtohtml = "pandoc %docroot% -o %outputfile%",
    mdtohtmlviewerlaunch = "zathura %outputfile%",
    mdtohtmlviewerrefresh = "zathura :reload",
    mdtohtmlforwardjump = nil,
    mdtohtmlshorterror = nil,

    -- R Markdown (.Rmd) settings for PDF output
    rmdoutputext = "pdf",
    rmdtopdf = "Rscript -e \"rmarkdown::render('%docroot%', output_file='output.pdf')\" 2> /tmp/rmarkdown_error.log",
    rmdtopdfviewerlaunch = "zathura output.pdf > /dev/null 2>&1 &",
    rmdtopdfviewerrefresh = "pkill -USR1 zathura > /dev/null 2>&1 &",
}


local kmap = vim.keymap.set
local opts = { noremap = true, silent = true }

local knap_ok, knap = pcall(require, 'knap')
if knap_ok then
    -- Process the document once and refresh the view
    kmap({ 'n', 'v', 'i' }, '<F7>', function() knap.process_once() end, opts)

    -- Close the viewer application and reset settings
    kmap({ 'n', 'v', 'i' }, '<F6>', function() knap.close_viewer() end, opts)

    -- Toggle auto-processing on and off
    -- kmap({ 'n', 'v', 'i' }, '<F7>', function() knap.toggle_autopreviewing() end, opts)

    -- Invoke a forward search (e.g., SyncTeX for LaTeX)
    -- kmap({ 'n', 'v', 'i' }, '<F8>', function() knap.forward_jump() end, opts)
else
    print("Error: knap plugin not loaded")
end
EOF

" ==========================================================================
" C Formatter (clang-format)
" ==========================================================================
" Map a key to run clang-format on the current buffer for C files
autocmd FileType c nnoremap <leader>cf :%!astyle<CR>

" ==========================================================================
" Tmux settings
" ==========================================================================
autocmd BufEnter * call system("tmux rename-window " . expand("%:t"))
autocmd VimLeave * call system("tmux rename-window bash")
autocmd BufEnter * let &titlestring = ' ' . expand("%:t")                                                                 
set title
