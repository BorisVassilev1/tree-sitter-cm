; highlights.scm

(Type) @type

(Id) @identifier
(IndId) @function
(Natural) @number
(Real) @number
(String) @string

(restr) @keyword
(in) @keyword
(subset) @keyword
(meets) @keyword
(forall) @keyword
(exists) @keyword
(if) @keyword
(otherwise) @keyword
(where) @keyword
(until) @keyword
(induction) @keyword
(step) @keyword
(is) @keyword
(rem) @keyword
(as) @keyword
(case) @keyword
(proj) @keyword
(func) @keyword
;(defined) @keyword


(UnOp) @operator
(MulOp) @operator
(AddOp) @operator
(EqOp) @operator
(def) @operator
(Quantor) @operator
(larrow) @operator

(Btype (Natural) @type)

(Comment) @comment

; Error highlighting.
;
; A failed parse produces nested ERROR nodes: a huge outer one (often the whole
; file / large multi-line spans) plus small inner ones around the token that
; actually tripped the parser. Flagging the big ones just paints the buffer
; red and says nothing, so we keep only single-line ERROR nodes - that lands
; the highlight on (or very close to) the real problem. `#not-match?` is
; understood by both Neovim and the `tree-sitter` CLI.
((ERROR) @comment.error
  (#not-match? @comment.error "[\r\n]"))

; A MISSING node marks the exact spot where the parser expected a token that
; was not supplied (shows up in :Inspect even though it is zero-width).
(MISSING) @comment.error

