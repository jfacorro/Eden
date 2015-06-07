ExEdn
=====

edn (extensible data notation) parser, encoder and decoder implemented in Elixir.

Grammar
=======

```
expr -> literal | map | list | vector | tagged_value
exprs -> expr exprs

literal -> nil | true | false | keyword | symbol | integer | float | string

map -> { pairs }
pairs -> pair pairs
pair -> expr expr

list -> ( exprs )

vector -> [ exprs ]

tagged_value -> tag expr
```