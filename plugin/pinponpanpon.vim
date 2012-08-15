" File:        pinponpanpon-vim
" Description: Vim plugin for checking weather warning announce from jma.go.jp
" Author:      Yasuhiro Asaka <y.grauwoelfchen@gmail.com>
" Last Change: 2012 Aug 15
" WebPage:     http://github.com/grauwoelfchen/pinponpanpon-vim
" Source:      http://www.jma.go.jp/jp/warn/
" License:     BSD
" Version:     0.1

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
  let name = a:0 > 0 ? a:1 : exists('g:pinponpanpon_area_name') ? g:pinponpanpon_area_name : ''
  let code = s:to_code(name)
  if empty(name) || empty(code)
    echohl WarningMsg
    echo "プー, プー..."
    echohl None
    return
  endif
  let base_url = 'http://www.jma.go.jp/jp/warn/'
  let res = webapi#http#get(base_url.code.'_table.html')
  let doc = webapi#html#parse(iconv(res.content, 'utf-8', &encoding))
  for a in doc.findAll('table', {'id':'WarnTableTable'})[0].findAll('a')
    if has_key(a.attr, 'href')
      if a.value() == name
        let hrf = a.attr['href']
        let res = webapi#http#get(base_url.hrf)
        let doc = webapi#html#parse(iconv(res.content, 'utf-8', &encoding))
        for t in doc.findAll('table', {'id':'WarnInfoTable'})[0].findAll('td')
          echo t.value()
          break
        endfor
      endif
    endif
  endfor
endfunction

command! -nargs=? PinponPanpon call <SID>PinponPanpon(<f-args>)
