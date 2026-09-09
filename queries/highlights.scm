; highlights.scm  --  C(m)
;
; Ordering matters: Neovim/tree-sitter let a later rule (and a rule on a deeper
; node) win. Generic rules come first; role-specific ones override. Builtins
; come before "declarations & definitions" so that a locally (re)defined name
; -- e.g. `map` in `remap_DFSA` -- is coloured as a user function at its
; definition site, not as the builtin it shadows.  (Shadowed *call* sites can't
; be resolved from a single query; see locals.scm.)

; ─────────────────────────────  identifiers  ─────────────────────────────
(Id)    @variable
(IndId) @variable

; ───────────────────────────────  literals  ─────────────────────────────
(Natural) @number
(Real)    @number.float
(String)  @string
; character constants are lexed as Natural ('a', '\n', 65, ...) — recolor the
; quoted form so it doesn't read as an integer
((Natural) @character (#match? @character "^[-+]?'"))

; ────────────────────────────────  types  ──────────────────────────────
(Btype (Id) @type)
(Btype (Id) @type . (Id) @type.parameter)        ; the Y in  X(Y)
(Btype (Natural) @type)                          ; the N in  N ^ BTYPE
((Id) @type.builtin
 (#any-of? @type.builtin "IN" "ZZ" "IR" "IB" "STRING"))

; call sites:  f( ... )
(Expr (Aexpr (Id) @function.call) . (PosOp (Exprl)))

; supplementary actions:  ACTION <- expr ;
((Stmt (TermL (Term (Id) @keyword)) . (larrow))
 (#any-of? @keyword "dump" "print" "assert" "store" "storeBin" "saveBin" "saveText"))
((Stmt (TermL (Term (Id) @keyword.import)) . (larrow))
 (#any-of? @keyword.import "import" "include"))

; ──────────────────  inductive step tag:  @0  @k  @i+1  ────────────────
(IndIdTag)          @attribute
(IndIdTag (Natural) @attribute)

; ──────────────────────────────  builtins  ────────────────────────────
(proj)    @function.builtin
(func)    @function.builtin
(defined) @constant.builtin

; boolean constants
((Id) @boolean (#any-of? @boolean "true" "false"))
; builtin objects
((Id) @constant.builtin (#any-of? @constant.builtin "argc" "mainResult"))

; builtin functions (from the language reference)
((Id) @function.builtin
 (#any-of? @function.builtin
   "set" "elementOf" "argmin" "argmax" "subst" "substl"
   "rows" "cols" "substMat" "substSubMatrix"
   "AND" "OR" "XOR" "NOT" "SHL" "SHR"
   "sin" "cos" "tan" "asin" "acos" "atan"
   "sinh" "cosh" "tanh" "asinh" "acosh" "atanh"
   "sqrt" "exp" "log" "log2" "log10"
   "erf" "tgamma" "lgamma"
   "floor" "ceil" "trunc" "round" "rint" "lrint"
   "str" "loadBin" "loadText" "restore" "restoreBin" "argv"))

; ─────────────────────  declarations & definitions  ────────────────────
; re-mark the identifier a statement introduces (wins over @variable AND over
; the builtin rules above)

; `NAME is TYPE ;`            → type alias
(Stmt (TermL (Term (Id) @type.definition)) . (is))

; `name in ... -> ... ;`      → function signature
(Stmt (TermL (Term (Id) @function)) . (in) (Type (arrow)))

; `f ( params ) := ...`       → function definition + its parameters
(Stmt
  (TermL (Term (Id) @function)) .
  (Term (TermL (Term (Id) @variable.parameter))) .
  (def))

; ──────────────────────────────  keywords  ────────────────────────────
[(induction) (step) (until)] @keyword.repeat
[(case) (otherwise) (if)]    @keyword.conditional
"?"                          @keyword.conditional
(where)                      @keyword
(Quantor)                    @keyword.operator      ; forall / exists
[(is) (as) (in) (subset) (meets) (rem)] @keyword.operator

; ─────────────────────────────  operators  ───────────────────────────
[(UnOp) (MulOp) (AddOp) (EqOp) (def) (larrow) (arrow) (newrow)
 (cap) (cup) (restr) (le) (ge) (eqv)] @operator
["^" "^*" "=" "&" "*" "+" "-" "‘"] @operator
(dd) @operator                                       ; ..

; ────────────────────────────  punctuation  ──────────────────────────
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
[(opmat) (clmat)]         @punctuation.bracket
[";" "," ":"] @punctuation.delimiter
["#" "|"]     @punctuation.special

; ────────────────────────────────  misc  ─────────────────────────────
(Comment) @comment

; ──────────────────────────  error highlighting  ─────────────────────
; A failed parse makes nested ERROR nodes: one huge outer span plus small
; inner ones at the token that tripped the parser. Flagging the big ones
; just reddens the buffer, so keep only single-line ERROR nodes.
; `#not-match?` works in both Neovim and the tree-sitter CLI.
((ERROR) @comment.error (#not-match? @comment.error "[\r\n]"))
(MISSING) @comment.error
