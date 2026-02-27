/**
 * @file the C(m) programming language
 * @author Boris Vassilev <boris.n.vassilev@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "cm",

  extras: $ => [
    /[\s\n]+/,
    $.Comment
  ],

  conflicts: $ => [
    //[$.Aexpr, $.Assignment],
    //[$.Term, $.Aexpr]
  ],

  rules: {
    source_file: $ => $.StmtL ,

    restr: $ => /\|_/,
    in: $ => /in/,
    subset: $ => /subset/,
    meets: $ => /meets/,
    cap: $ => /\/\\/,
    cup: $ => /\\\//,
    le: $ => /<=/,
    ge: $ => />=/,
    dd: $ => /\.\./,
    forall: $ => /forall/,
    exists: $ => /exists/,
    if: $ => "if",
    otherwise: $ => /otherwise/,
    where: $ => /where/,
    eqv: $ => /<->/,
    until: $ => /until/,
    induction: $ => /induction/,
    step: $ => /step/,
    is: $ => /is/,
    def: $ => /:=/,
    arrow: $ => /->/,
    rem: $ => /rem/,
    as: $ => /as/,
    case: $ => /case/,
    opmat: $ => /\[:/,
    clmat: $ => /:\]/,
    newrow: $ => /\\\\/,
    larrow: $ => /<-/,
    proj: $ => /Proj/,
    func: $ => /Func/,
    defined: $ => /Defined/,

    Id: $ => $._Id,
    _Id: $ => /[a-zA-Z][a-zA-Z0-9_']*/,
    IndId: $ => seq($._Id, '@', choice(
      seq($._Id, optional('+1')),
      '0'
    )),

    Natural: $ => /[-+]?[1-9][0-9]*|0|'.'/,
    Real: $ => /[-+]?(?:[0-9]+\.[0-9]*|[0-9]*\.[0-9]+)(?:[eE][-+]?[0-9]+)?/,
    String: $ => /"([^"\\]|\\.)*"/,
    Char: $ => /'([^'\\]|\\.)*'/,

    UnOp: $ => choice('+', '-', $.cup, '!', '~', '.'),
    MulOp: $ => choice('/', '\\\\', $.restr, $.rem, 
        seq('.', optional(choice('*', '/', '^')))
    ),
    AddOp: $ => choice('+', '-', $.cap, $.cup, $.arrow, $.eqv),
    EqOp: $ => choice('=', '<', '>', $.le, $.ge, $.in, $.subset, $.meets, 
        seq('~', choice($.in, $ .subset, $ .meets, '='))
    ),
    Quantor: $ => choice($.forall, $.exists),
    
    Type: $ => seq($.Dtype, repeat(seq($.arrow, $.Dtype))),
    Dtype: $ => seq($.Ctype, repeat(seq('*', $.Ctype))),
    Ctype: $ => seq($.Btype, repeat("^*")),
    Btype: $ => choice(
      seq($.Id, optional(seq('(', $.Id, ')'))),
      seq('(', $.Type, ')'),
      seq($.Natural, '^', $.Btype)
    ),
    
    Aexpr: $ => prec.right(choice(
      $.Natural,
      $.Real,
      $.String,
      $.Char,
      $.Id,
      $.IndId,
      $.Case,
      seq('|', $.Expr, '|'),
      seq('(', $.Exprl, ')'),
      seq('#', '(', $.Expr, ',', $.Expr, ')'),
      seq($.proj, '(', $.Expr, ',', $.Expr, ')'),
      seq($.func, '(', $.Expr, ',', $.Expr, ',', $.Expr, ')'),
      seq($.if, '(', $.Expr, ',', $.Expr, ',', $.Expr, ')'),
      seq('{', optional(seq($.Expr, 
        choice(seq(',', $.Exprl), seq($.dd, $.Expr), seq('|', $.TermExprl))
      )), '}'),
      seq('[', optional(seq($.Expr, 
        choice(seq(',', $.Exprl), seq($.dd, $.Expr), seq('|', $.TermExprl))
      )), ']'),
      seq($.opmat, $.Expr, optional(choice(
        seq(',', $.Exprl),
        seq('|', repeat1(seq($.Id, '=', $.Natural, $.dd, $.Expr)))
      )), $.clmat),
      seq($.Quantor, $.TermExprl, ':', '(', $.Expr, ')')
    )),
    
    //Case: $ => seq('?', $.Expr, $.if, choice($.defined, $.Expr), choice($.otherwise, $.Case)),
    Case: $ => seq('?', $.Expr, choice(
      seq($.if, choice($.defined, $.Expr), $.Case),
      $.otherwise
    )),
    PosOp: $ => choice(
      seq('(', $.Exprl, ')'),
      seq('[', $.Expr, optional(choice(seq($.dd, $.Expr), seq(',', $.Expr))), ']'),
      '‘'
    ),
    _PosExpr: $ => seq($.Aexpr, repeat($.PosOp)),
    _UnExpr: $ => seq(repeat($.UnOp), $._PosExpr),
    _PowExpr: $ => seq($._UnExpr, repeat(seq('^', $._UnExpr))),
    _TmsExpr: $ => seq($._PowExpr, repeat(seq('*', $._PowExpr))),
    _MulExpr: $ => seq($._TmsExpr, repeat(seq($.MulOp, $._TmsExpr))),
    _AddExpr: $ => seq($._MulExpr, repeat(seq($.AddOp, $._MulExpr))),
    _MatExpr: $ => seq($._AddExpr, repeat(seq($.newrow, $._AddExpr))),
    _EqExpr: $ => seq($._MatExpr, repeat(seq($.EqOp, $._MatExpr))),
    Expr: $ => seq($._EqExpr, optional(seq($.as, $.Type))),

    Exprl: $ => seq($.Expr, repeat(seq(',', $.Expr))),

    Term: $ => prec(2, choice(
      $.Id, 
      $.IndId,
      $.Natural,
      $.Real,
      $.String,
      seq('(', $.TermL, ')'),
    )),
    TermL: $ => seq($.Term, repeat(seq(',', $.Term))),

    TermExpr: $ => seq($.Term, choice($.in, '='), $.Expr, optional(seq('&', $.Expr))),
    TermExprl: $ => seq($.TermExpr, repeat(seq(',', $.TermExpr))),

    Assignment: $ => choice(
      seq($.Expr, optional(seq(',', $.where, $.StmtL))),
      seq(
        repeat1(seq($.case, $.Expr, ':', $.Expr, optional(seq(',', $.where, $.StmtL)))),
        optional(seq($.otherwise, ':', $.Expr, optional(seq(',', $.where, $.StmtL))))
      ),
      seq(
        $.induction, '\n', 
        $.step, $.Natural, ':', $.StmtL, '\n',
        $.step, $.Id, '+', $.Natural, ':', $.StmtL, '\n', 
        $.until, $.Expr
      )
    ),
    Stmt: $ => seq($.TermL, choice(
      seq($.is, $.Type),
      seq($.in, $.Type),
      seq(optional($.Term), $.def, $.Assignment),
      seq($.larrow, $.Expr),
    )),
    StmtL: $ => repeat1(seq($.Stmt, ';')),

    Comment: ($) =>
      token(
        choice(seq("//", /.*/), seq("/*", /[^*]*\*+([^/*][^*]*\*+)*/, "/")),
      ),
  }
});
