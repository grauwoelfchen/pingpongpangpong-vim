" File:        pinponpanpon-vim
" Description: Vim plugin for checking weather warning announce from jma.go.jp
" Author:      Yasuhiro Asaka <y.grauwoelfchen@gmail.com>
" Last Change: 2012 Sep 02
" WebPage:     http://github.com/grauwoelfchen/pinponpanpon-vim
" Source:      http://www.jma.go.jp/jp/warn/
" License:     BSD
" Version:     0.0.3

scriptencoding utf-8
if exists('g:loaded_pinponpanpon_vim')
  finish
endif
let g:loaded_pinponpanpon_vim = 1

let s:json = {}
let s:path = expand('<sfile>:h').'/area.json'

function! s:load_json()
  if empty(s:json)
    let s:json = webapi#json#decode(join(readfile(s:path), "\n"))
  endif
endfunction

function! s:search_code(area)
  if has_key(s:json, a:area)
    return s:json[a:area]
  endif
endfunction

function! s:to_code(area)
  call s:load_json()
  return s:search_code(a:area)
endfunction

function! s:fetch(file)
  let base_url = 'http://www.jma.go.jp/jp/warn/'
  let response = webapi#http#get(base_url.a:file)
  if a:file =~ '_table.html'
    " jma.go.jp has broken table ;(
    let html = substitute(response.content, "</tr></tr>", "</tr>", 'g')
  else
    let html = response.content
  endif
  return webapi#html#parse(iconv(html, 'utf-8', &encoding))
endfunction

function! s:draw(state)
  redraw | echo a:state
endfunction

function! s:bufopen_or_focus()
  " use same bufwinnr C-w
  let winnr = bufwinnr(bufnr('^PinponPanpon$'))
  if winnr != -1
    if winnr != bufwinnr('%')
      execute winnr.'wincmd w'
    endif
  else
    execute 'silent noautocmd botright split PinponPanpon'
  endif
endfunction

function! s:show(info)
  setlocal modifiable
  silent %d _
  call setline(1, split(a:info, "\n"))
  setlocal buftype=nofile bufhidden=hide noswapfile
  setlocal nomodifiable
endfunction

function! s:PinponPanpon(...)
  let area = a:0 > 0 ? a:1 : exists('g:pinponpanpon_area_name') ? g:pinponpanpon_area_name : ''
  let code = s:to_code(area)
  if !(empty(area) || empty(code))
    call s:draw('fetching data...')
    let doc = s:fetch(code.'_table.html')
    call s:draw('parsing data...')
    for a in doc.findAll('table', {'id':'WarnTableTable'})[0].findAll('a')
      if has_key(a.attr, 'href')
        if a.value() == area
          call s:draw('fetching info...')
          let doc = s:fetch(a.attr['href'])
          call s:draw('parsing info...')
          for td in doc.findAll('table', {'id':'WarnInfoTable'})[0].findAll('td')
            if !empty(td.value())
              call s:draw('')
              call s:bufopen_or_focus()
              call s:show(td.value())
              return
            endif
          endfor
        endif
      endif
    endfor
    call s:draw('')
  endif
  " not found
  echohl WarningMsg | call s:draw('プー, プー...') | echohl None
  sleep 2
  call s:draw('')
endfunction

command! -nargs=? PinponPanpon call <SID>PinponPanpon(<f-args>)
