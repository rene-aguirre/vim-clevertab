"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! CleverTab#Complete(type)
  "echom "type: " . a:type

  if a:type == 'start'
    if has("autocmd")
      augroup CleverTabAu
        autocmd CursorMovedI * if pumvisible() == 0 && g:CleverTab#autocmd_set|let g:CleverTab#autocmd_set = 0|pclose|call CleverTab#ClearAutocmds()|endif
        autocmd InsertLeave *  if pumvisible() == 0 && g:CleverTab#autocmd_set|let g:CleverTab#autocmd_set = 0|pclose|call CleverTab#ClearAutocmds()|endif
      augroup END
    endif
    if !exists("g:CleverTab#next_step_direction")
      echom "Clevertab Start"
      let g:CleverTab#next_step_direction="0"
    else
      echom "tab start"
    endif
    let g:CleverTab#last_cursor_col=virtcol('.')
    let g:CleverTab#cursor_moved=0
    let g:CleverTab#eat_next=0
    let g:CleverTab#autocmd_set=1
    let g:CleverTab#stop=0
    let l:leftOfCursor=strpart(getline('.'), 0, col('.')-1)
    let l:rightOfCursor=strpart(getline('.'), col('.')-1, col('$'))
    let g:CleverTab#word_ends=(l:leftOfCursor =~ '\w$' && (l:rightOfCursor == '' || l:rightOfCursor =~ '^\W'))
    let g:CleverTab#path_starts=(l:leftOfCursor =~ '/$' && (l:rightOfCursor == '' || l:rightOfCursor =~ '^\W'))
    echom "LoC='" . l:leftOfCursor . "'"
    echom "RoC='" . l:rightOfCursor . "'"
    if g:CleverTab#word_ends
        echom "word ends"
    endif
    if g:CleverTab#path_starts
        echom "path starts"
    endif
  endif
  let g:CleverTab#cursor_moved=g:CleverTab#last_cursor_col!=virtcol('.')

  if a:type == 'tab' && !g:CleverTab#stop
    if (col('.') == 1) || !(g:CleverTab#word_ends || g:CleverTab#path_starts)
      let g:CleverTab#stop=1
      echom "Regular Tab"
      let g:CleverTab#next_step_direction="0"
      return "\<TAB>"
    endif

  elseif a:type == 'omni' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    if &omnifunc != '' && g:CleverTab#word_ends 
      echom "Omni Complete"
      let g:CleverTab#next_step_direction="N"
      let g:CleverTab#eat_next=1
      return "\<C-X>\<C-O>"
    endif

  elseif a:type == 'user' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    if &completefunc != '' && g:CleverTab#word_ends
      echom "User Complete"
      let g:CleverTab#next_step_direction="N"
      let g:CleverTab#eat_next=1
      return "\<C-X>\<C-U>"
    endif

  elseif a:type == "file" && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    if g:CleverTab#word_ends || g:CleverTab#path_starts
      echom "File Complete"
      let g:CleverTab#next_step_direction="N"
      let g:CleverTab#eat_next=1
      return "\<C-X>\<C-F>"
    endif

  elseif a:type == 'keyword' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    if g:CleverTab#word_ends
      echom "Keyword Complete"
      let g:CleverTab#next_step_direction="N"
      let g:CleverTab#eat_next=1
      return "\<C-X>\<C-N>"
    endif

  elseif a:type == 'dictionary' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    if g:CleverTab#word_ends
        echom "Dictionary Complete"
        let g:CleverTab#next_step_direction="P"
        let g:CleverTab#eat_next=1
        return "\<C-X>\<C-K>"
    endif

  elseif a:type == 'neocomplete' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    echom "NeoComplete"
    let g:CleverTab#next_step_direction="N"
    let g:CleverTab#eat_next=1
    try
        let l:result = neocomplete#start_manual_complete()
    catch
        return ""
    endtry
    return l:result

  elseif a:type == 'neosnippet' && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    try
        let g:neo_snip_x = neosnippet#mappings#expand_or_jump_impl()
    catch
        return ""
    endtry
    if neosnippet#expandable_or_jumpable()
      echom "NeoSnippet"
      let g:CleverTab#next_step_direction="0"
      let g:CleverTab#stop=1
      return g:neo_snip_x
    endif
    return ""

  elseif a:type == 'ultisnips' && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    try
        let g:ulti_x = UltiSnips#ExpandSnippetOrJump()
    catch
        return ""
    endtry
    if g:ulti_expand_or_jump_res
    echom "Ultisnips"
    let g:CleverTab#next_step_direction="0"
    let g:CleverTab#stop=1
    return g:ulti_x
    endif
    return ""

  elseif a:type == 'forcedtab' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    echom "forcedtab"
    let g:CleverTab#next_step_direction="0"
    let g:CleverTab#stop=1
    return "\<Tab>"

  elseif a:type == "stop" || a:type == "next"
    if !g:CleverTab#stop && pumvisible() && g:CleverTab#next_step_direction=="0"
        echom "next setup"
        let g:CleverTab#next_step_direction="N"
        " let g:CleverTab#eat_next=1
    endif
    if g:CleverTab#stop || g:CleverTab#eat_next==1
      echom "sink tab"
      let g:CleverTab#stop=0
      let g:CleverTab#eat_next=0
      return ""
    endif
    if g:CleverTab#next_step_direction=="P"
      echom "next-backward"
      let g:CleverTab#stop=1
      return "\<C-P>"
    elseif g:CleverTab#next_step_direction=="N"
      echom "next-forward"
      let g:CleverTab#stop=1
      return "\<C-N>"
    endif

  elseif a:type == "prev"
    if g:CleverTab#next_step_direction=="P"
      return "\<C-N>"
    elseif g:CleverTab#next_step_direction=="N"
      return "\<C-P>"
    else
      return "\<Tab>"
    endif
  endif

  message "Sink type=" . a:type
  return ""
endfunction

function! CleverTab#OmniFirst()
  inoremap <silent><tab> <c-r>=CleverTab#Complete('start')<cr>
                        \<c-r>=CleverTab#Complete('tab')<cr>
                        \<c-r>=CleverTab#Complete('ultisnips')<cr>
                        \<c-r>=CleverTab#Complete('omni')<cr>
                        \<c-r>=CleverTab#Complete('keyword')<cr>
                        \<c-r>=CleverTab#Complete('user')<cr>
                        \<c-r>=CleverTab#Complete('stop')<cr>
  inoremap <silent><s-tab> <c-r>=CleverTab#Complete('prev')<cr>
endfunction

function! CleverTab#KeywordFirst()
  inoremap <silent><tab> <c-r>=CleverTab#Complete('start')<cr>
                        \<c-r>=CleverTab#Complete('tab')<cr>
                        \<c-r>=CleverTab#Complete('ultisnips')<cr>
                        \<c-r>=CleverTab#Complete('keyword')<cr>
                        \<c-r>=CleverTab#Complete('user')<cr>
                        \<c-r>=CleverTab#Complete('neocomplete')<cr>
                        \<c-r>=CleverTab#Complete('omni')<cr>
                        \<c-r>=CleverTab#Complete('stop')<cr>
  inoremap <silent><s-tab> <c-r>=CleverTab#Complete('prev')<cr>
endfunction

function! CleverTab#NeoCompleteFirst()
  inoremap <silent><tab> <c-r>=CleverTab#Complete('start')<cr>
                        \<c-r>=CleverTab#Complete('tab')<cr>
                        \<c-r>=CleverTab#Complete('ultisnips')<cr>
                        \<c-r>=CleverTab#Complete('neocomplete')<cr>
                        \<c-r>=CleverTab#Complete('keyword')<cr>
                        \<c-r>=CleverTab#Complete('omni')<cr>
                        \<c-r>=CleverTab#Complete('user')<cr>
                        \<c-r>=CleverTab#Complete('stop')<cr>
  inoremap <silent><s-tab> <c-r>=CleverTab#Complete('prev')<cr>
endfunction

function! CleverTab#ClearAutocmds()
  autocmd! CleverTabAu InsertLeave *
  autocmd! CleverTabAu CursorMovedI *
endfunction
