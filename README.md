# pingpongpangpong-vim

Let's check japanese weather warning Announce in Vim.

ping pong pang pong ♪

## Require

* [webapi-vim](https://github.com/mattn/webapi-vim)

## Usage

see `doc/pingpongpangpong-vim.txt`

```
:PingPongPangPong さいたま市

or set in .vimrc

g:pingpongpangpong_area_name = 'さいたま市'
```
## Source

* [Japan Meteorological Agency](http://www.jma.go.jp/jp/warn/)

## Changelog

Version 0.0.5

```
* 2014-01-09
  - Rename to pingpongpangpong.
* 2012-09-02
  - Added missing area.
  - Refactored code.
* 2012-08-29
  - Improved window and buffer handling.
  - Added indicator message (fetching/parsing).
* 2012-08-25
  - Solved parse error caused by broken table.
* 2012-08-24
  - Updated doc text.
* 2012-08-15
  - Initial version.
```

## Todo

* add all prefectures.
* color highlight.
* add sound :)
