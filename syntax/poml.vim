" Vim syntax highlighting for "Poml", a block structure markup
" language, and "Tetanus", a rudimentary inline markup language
" intended for use with Poml.
"
" Maintainer: https://github.com/malleusinferni/

if version < 600
  syn clear
elseif exists("b:current_syntax")
  finish
endif

setlocal iskeyword=@,48-57,_,#,.
syn sync fromstart

" ==============================================================

syn match tetanusFunc "\\\w\+" contained

" Mismatched braces are flagged as errors.
syn match tetanusBraceError "\({\|}\)" contained

" Overrides the previous highlight group.
syn region tetanusArg
      \ matchgroup=tetanusBraces
      \ start="{" end="}"
      \ oneline
      \ contains=tetanusFunc,tetanusArg,tetanusBraceError
      \ contained

hi def link tetanusFunc Function
hi def link tetanusBraces Delimiter
hi def link tetanusBraceError Error

" ==============================================================

" Default/fallback Poml syntax. Special cases defined later on will
" override this.
syn region pomlBlockHeader
      \ start="^#" end="$"
      \ oneline
      \ transparent
      \ contains=pomlKeyword,pomlKeywordArg,pomlNumericArg

syn match pomlKeywordArg "\<\S\+\>" contained
syn match pomlNumericArg "\<\d\+\>" contained
syn match pomlKeyword "^#\+\w\+" contained

" Matches "fooBar" (etc.) inside a chatlog
syn match pomlCamelCase "\<[a-z]\+[A-Z][a-z]\+\>"
      \ contained

" Abbreviated local or ISO-8601 (Zulu time) formats.
"
" Local example: "2013-11-15 18:09"
" Zulu example: "2013-11-15T18:09:57Z"
"
" Order should always be YYYY-MM-DD, so dates which are clearly not in
" that order (eg. 2013-31-10) will show up as errors. Not all such
" errors can be easily detected without a more complicated parser.
syn region pomlTimestamp
      \ matchgroup=pomlKeyword
      \ start="^#TS" end="$"
      \ oneline
      \ transparent
      \ contains=pomlDateFormat,pomlDateError
syn match pomlDateError "\S*" contained
syn match pomlDateFormat
      \ "\d\{4}-[0-1]\d-[0-3]\d\( [0-1]\d:[0-5]\d\|T[0-1]\d:[0-5]\d:[0-5]\dZ\)"
      \ contained

" Page title. Argument string may contain markup, eg. \emote{==>}
syn region pomlTitle
      \ matchgroup=pomlKeyword
      \ start="^#\(PAGE\|TITLE\)" end="$"
      \ oneline
      \ contains=tetanusFunc,tetanusArg,tetanusBraceError

" Normal blocks of text.
" FIXME Match paragraph attribute keywords
syn region pomlParagraph
      \ matchgroup=pomlKeyword
      \ start="^#\(P\|NARRATION\)$" end="\(^#\)\@="
      \ transparent
      \ contains=tetanusFunc,tetanusArg,tetanusBraceError

" Chatlogs are highlighted using a combination of two groups
" because of the likelihood that their headers include arguments.
syn match pomlLogHeader
      \ "^#[A-Z]\+LOG.*\n"
      \ contains=pomlKeyword,pomlKeywordArg
      \ nextgroup=pomlChatlog
" FIXME Doesn't always match correctly, especially on empty blocks
syn region pomlChatlog
      \ start="[^#]" end="\(^#\)\@="
      \ contained
      \ transparent
      \ contains=tetanusFunc,tetanusArg,tetanusBraceError,pomlCamelCase

hi def link pomlCamelCase Label
hi def link pomlTitle Title
hi def link pomlDateFormat Comment
hi def link pomlDateError Error
hi def link pomlKeyword Keyword
hi def link pomlKeywordArg PreProc
hi def link pomlNumericArg Number
