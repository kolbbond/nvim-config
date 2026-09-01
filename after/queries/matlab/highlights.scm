;; extends

; `%% Section` cell markers. The grammar parses these as plain comments, so
; match on the text -- in a Lua pattern `%%` is one literal `%`.
; Colored via the @section.matlab link in after/plugin/treesitter.lua.
((comment) @section
  (#lua-match? @section "^%%%%"))
