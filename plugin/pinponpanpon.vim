" File:        pinponpanpon-vim
" Description: Vim plugin for checking weather warning announce from jma.go.jp
" Author:      Yasuhiro Asaka <y.grauwoelfchen@gmail.com>
" Last Change: 2012 Aug 15
" WebPage:     http://github.com/grauwoelfchen/pinponpanpon-vim
" Source:      http://www.jma.go.jp/jp/warn/
" License:     BSD
" Version:     0.0.2

scriptencoding utf-8
if exists('g:loaded_pinponpanpon_vim')
  finish
endif

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
  let s:name = a:0 > 0 ? a:1 : exists('g:pinponpanpon_area_name') ? g:pinponpanpon_area_name : ''
  let s:code = s:to_code(s:name)
  let s:found = 0
  if !(empty(s:name) || empty(s:code))
    let s:base_url = 'http://www.jma.go.jp/jp/warn/'
    let s:response = webapi#http#get(s:base_url.s:code.'_table.html')
    " jma.go.jp has broken table ;(
    let s:replaced = substitute(s:response.content, '</tr></tr><tr>', '</tr><tr>', 'g')
    let s:document = webapi#html#parse(iconv(s:replaced, 'utf-8', &encoding))
    for a in s:document.findAll('table', {'id':'WarnTableTable'})[0].findAll('a')
      if has_key(a.attr, 'href')
        if a.value() == s:name
          let s:attr_hrf = a.attr['href']
          let s:response = webapi#http#get(s:base_url.s:attr_hrf)
          let s:document = webapi#html#parse(iconv(s:response.content, 'utf-8', &encoding))
          for d in s:document.findAll('table', {'id':'WarnInfoTable'})[0].findAll('td')
            let s:found = 1
            echo d.value()
            break
          endfor
        endif
      endif
    endfor
  endif
  if !s:found
    echohl WarningMsg
    echo "プー, プー..."
    echohl None
  endif
endfunction

command! -nargs=? PinponPanpon call <SID>PinponPanpon(<f-args>)
