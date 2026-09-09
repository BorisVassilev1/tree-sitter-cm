; locals.scm  --  C(m)  scope / definition tracking
;
; Best-effort. Powers name-aware motions (]f / [f), incremental selection and
; rename. Neovim core's *highlighter* does not consult this file, so a builtin
; name shadowed by a local (e.g. `map` in `remap_DFSA`) is still coloured as
; the builtin at its *call* sites -- its definition sites are handled in
; highlights.scm by ordering. Editors with a locals-aware highlighter
; (Helix, ...) can use the data here for full shadowing.

; ───────────────────────────────  scopes  ──────────────────────────────
; `where`-block bindings live in the Assignment so they're visible to the head
; expression that precedes `where`; the outer Stmt scopes the parameters.
(Stmt) @local.scope
(Assignment) @local.scope
(Aexpr (TermExprl)) @local.scope          ; { e | x in S } , [ e | .. ] , forall x : ..

; ────────────────────────────  definitions  ────────────────────────────

; `NAME is TYPE ;`
(Stmt (TermL (Term (Id) @local.definition.type)) . (is))

; `name in TYPE ;`     (function signature or plain declaration)
(Stmt (TermL (Term (Id) @local.definition.var)) . (in))

; `f ( params ) := ...`   /   `name := ...`   /   `(a, b) := ...`
(Stmt (TermL (Term (Id) @local.definition.function)) . (Term) . (def))
(Stmt (TermL (Term (Id) @local.definition.var)) . (def))
(Stmt (TermL (Term (TermL (Term (Id) @local.definition.var)))) . (def))
(Stmt
  (TermL (Term (Id))) .
  (Term (TermL (Term (Id) @local.definition.parameter))) .
  (def))
(Stmt
  (TermL (Term (Id))) .
  (Term (TermL (Term (TermL (Term (Id) @local.definition.parameter))))) .
  (def))

; `step i+1 :`  → the induction variable
(Assignment (step) (Id) @local.definition.var)

; comprehension / quantifier binders
(TermExpr (Term (Id) @local.definition.var))
(TermExpr (Term (TermL (Term (Id) @local.definition.var))))

; ────────────────────────────  references  ─────────────────────────────
(Id) @local.reference
