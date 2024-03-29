;; extends
; Section comment highlighting

["%%"] @section
["test"] @test

((identifier) @section (#eq? @section "%%"))
