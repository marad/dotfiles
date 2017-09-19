let g:vrc_auto_format_response_enabled = 1
let g:vrc_response_default_content_type = 'json'

let g:vrc_curl_opts = {
  \ '--connect-timeout' : 10,
  \ '-i': '',
  \ '-sS': '',
\}

" let g:vrc_auto_format_response_patterns = {
"     \  'json': 'python -m json.tool',
"     \  'json;charset=UTF-8': 'python -m json.tool',
"     \ }
