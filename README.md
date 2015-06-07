ExEdn
=====

** TODO: Add description **

Grammar
=======

expr -> literal | map | list | vector | tagged_value
exprs -> expr exprs

literal -> nil | true | false | keyword | symbol | integer | float

map -> { pairs }
pairs -> pair pairs
pair -> expr expr

list -> ( exprs )

vector -> [ exprs ]

tagged_value -> tag expr