" Vim filetype plugin file
" Language:		R Markdown file
" Maintainer:		This runtime file is looking for a new maintainer.
" Former Maintainer:	Jakson Alves de Aquino <jalvesaq@gmail.com>
" Former Repository:	https://github.com/jalvesaq/R-Vim-runtime
" Last Change:		2024 Feb 28 by Vim Project
" Original work by Alex Zvoleff (adjusted from R help for rmd by Michel Kuhlmann)

" Only do this when not yet done for this buffer
if exists("b:did_ftplugin")
  finish
endif

if exists('g:rmd_include_html') && g:rmd_include_html
  runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim
endif

setlocal comments=fb:*,fb:-,fb:+,n:>
setlocal commentstring=#\ %s
setlocal formatoptions+=tcqln
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*[-*+]\\s\\+
setlocal iskeyword=@,48-57,_,.

let s:cpo_save = &cpo
set cpo&vim

function FormatRmd()
  if search("^[ \t]*```[ ]*{r", "bncW") > search("^[ \t]*```$", "bncW")
    setlocal comments=:#',:###,:##,:#
  else
    setlocal comments=fb:*,fb:-,fb:+,n:>
  endif
  return 1
endfunction

let s:last_line = 0
function SetRmdCommentStr()
  if line('.') == s:last_line
    return
  endif
  let s:last_line = line('.')

  if (search("^[ \t]*```[ ]*{r", "bncW") > search("^[ \t]*```$", "bncW")) || ((search('^---$', 'Wn') || search('^\.\.\.$', 'Wn')) && search('^---$', 'bnW'))
    set commentstring=#\ %s
  else
    set commentstring=<!--\ %s\ -->
  endif
endfunction

" If you do not want both 'comments' and 'commentstring' dynamically defined,
" put in your vimrc: let g:rmd_dynamic_comments = 0
if !exists("g:rmd_dynamic_comments") || (exists("g:rmd_dynamic_comments") && g:rmd_dynamic_comments == 1)
  setlocal formatexpr=FormatRmd()
  augroup RmdCStr
    autocmd!
    autocmd CursorMoved <buffer> call SetRmdCommentStr()
  augroup END
endif

" Enables pandoc if it is installed
unlet! b:did_ftplugin
runtime ftplugin/pandoc.vim

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

if (has("gui_win32") || has("gui_gtk")) && !exists("b:browsefilter")
  let b:browsefilter = "R Source Files (*.R, *.Rnw, *.Rd, *.Rmd, *.Rrst, *.qmd)\t*.R;*.Rnw;*.Rd;*.Rmd;*.Rrst;*.qmd\n"
  if has("win32")
    let b:browsefilter .= "All Files (*.*)\t*\n"
  else
    let b:browsefilter .= "All Files (*)\t*\n"
  endif
endif

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= " | setl cms< com< fo< flp< isk< | unlet! b:browsefilter"
else
  let b:undo_ftplugin = "setl cms< com< fo< flp< isk< | unlet! b:browsefilter"
endif

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2
"
" Vim filetype plugin
" Language:		Markdown
" Maintainer:		Tim Pope <vimNOSPAM@tpope.org>
" Last Change:		2019 Dec 05

" telekasten.nvim essentially deals with markdown, so we have to offer the
" same

if exists("b:did_ftplugin")
  finish
endif

runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim

setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=<!--%s-->
setlocal formatoptions+=tcqln formatoptions-=r formatoptions-=o
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^[-*+]\\s\\+\\\|^\\[^\\ze[^\\]]\\+\\]:

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= "|setl cms< com< fo< flp<"
else
  let b:undo_ftplugin = "setl cms< com< fo< flp<"
endif

function! s:NotCodeBlock(lnum) abort
  return synIDattr(synID(v:lnum, 1, 1), 'name') !=# 'markdownCode'
endfunction

function! MarkdownFold() abort
  let line = getline(v:lnum)

  if line =~# '^#\+ ' && s:NotCodeBlock(v:lnum)
    return ">" . match(line, ' ')
  endif

  let nextline = getline(v:lnum + 1)
  if (line =~ '^.\+$') && (nextline =~ '^=\+$') && s:NotCodeBlock(v:lnum + 1)
    return ">1"
  endif

  if (line =~ '^.\+$') && (nextline =~ '^-\+$') && s:NotCodeBlock(v:lnum + 1)
    return ">2"
  endif

  return "="
endfunction

function! s:HashIndent(lnum) abort
  let hash_header = matchstr(getline(a:lnum), '^#\{1,6}')
  if len(hash_header)
    return hash_header
  else
    let nextline = getline(a:lnum + 1)
    if nextline =~# '^=\+\s*$'
      return '#'
    elseif nextline =~# '^-\+\s*$'
      return '##'
    endif
  endif
endfunction

function! MarkdownFoldText() abort
  let hash_indent = s:HashIndent(v:foldstart)
  let title = substitute(getline(v:foldstart), '^#\+\s*', '', '')
  let foldsize = (v:foldend - v:foldstart + 1)
  let linecount = '['.foldsize.' lines]'
  return hash_indent.' '.title.' '.linecount
endfunction

if has("folding") && exists("g:markdown_folding")
  setlocal foldexpr=MarkdownFold()
  setlocal foldmethod=expr
  setlocal foldtext=MarkdownFoldText()
  let b:undo_ftplugin .= " foldexpr< foldmethod< foldtext<"
endif

" vim:set sw=2:
