" File:        pinponpanpon-vim
" Description: Vim plugin for checking weather warning announce from jma.go.jp
" Author:      Yasuhiro Asaka <y.grauwoelfchen@gmail.com>
" Last Change: 2012 Aug 29
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
let s:file = expand('<sfile>:h').'/area.json'

function! s:load_area()
  if empty(s:json)
    let s:json = webapi#json#decode(join(readfile(s:file), "\n"))
  endif
endfunction

function! s:search_area(n)
  if has_key(s:json, a:n)
    return s:json[a:n]
  end
endfunction

function! s:to_code(n)
  call s:load_area()
  return s:search_area(a:n)
endfunction

function! s:PinponPanpon(...)
  let l:name = a:0 > 0 ? a:1 : exists('g:pinponpanpon_area_name') ? g:pinponpanpon_area_name : ''
  let l:code = s:to_code(l:name)
  if !(empty(l:name) || empty(l:code))
    setlocal modifiable
    redraw | echo 'fetching data...'
    let l:base_url = 'http://www.jma.go.jp/jp/warn/'
    let l:response = webapi#http#get(l:base_url.l:code.'_table.html')
    " jma.go.jp has broken table ;(
    let l:replaced = substitute(l:response.content, "</tr></tr>", "</tr>", 'g')
    let l:document = webapi#html#parse(iconv(l:replaced, 'utf-8', &encoding))
    redraw | echo 'parsing data...'
    for a in l:document.findAll('table', {'id':'WarnTableTable'})[0].findAll('a')
      if has_key(a.attr, 'href')
        if a.value() == l:name
          redraw | echo 'fetching info...'
          let l:attr_hrf = a.attr['href']
          let l:response = webapi#http#get(l:base_url.l:attr_hrf)
          let l:document = webapi#html#parse(iconv(l:response.content, 'utf-8', &encoding))
          redraw | echo 'parsing info...'
          for td in l:document.findAll('table', {'id':'WarnInfoTable'})[0].findAll('td')
            if !empty(td.value())
              redraw | echo ''
              " use same bufwinnr C-w
              let l:winnr = bufwinnr(bufnr('^PinponPanpon$'))
              if l:winnr != -1
                if l:winnr != bufwinnr('%')
                  execute l:winnr.'wincmd w'
                endif
              else
                execute 'silent noautocmd botright split PinponPanpon'
              endif
              setlocal modifiable
              silent %d _
              call setline(1, split(td.value(), "\n"))
              setlocal buftype=nofile bufhidden=hide noswapfile
              setlocal nomodifiable
              return
            endif
          endfor
        endif
      endif
    endfor
    redraw | echo ''
  endif
  " not found
  echohl WarningMsg
  echo "プー, プー..."
  echohl None
  sleep 2
  redraw | echo ''
endfunction

command! -nargs=? PinponPanpon call <SID>PinponPanpon(<f-args>)
