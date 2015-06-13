ExEdn
=====

[![Travis](https://img.shields.io/travis/jfacorro/ExEdn.svg?style=flat-square)](https://travis-ci.org/jfacorro/ExEdn)

[edn](https://github.com/edn-format/edn) (extensible data notation) encoder/decoder implemented in Elixir.

## Data Structures Mapping: **edn** <-> **Elixir**

|  Edn | Elixir   |
|---|---|
| `nil`      | `:nil = nil` |
| `true`   | `:true = true` |
| `false`  | `:false = false` |
| `string` | `String` |
| `character` | `ExEdn.Character` |
| `symbol`  | `ExEdn.Symbol` |
| `keyword`  | `Atom` |
| `integer`  | `Integer` |
| `float`  | `Float` |
| `list`  | `List`  |
| `vector`  | `Array`  |
| `map`  | `Map` |
| `set`  | `HashSet` |
| `#inst`  | `Timex.DateTime` |
| `#uuid`  | `ExEdn.UUID` |

## Further Considerations

### `Character`

There is no way of distinguishing a common integer from the representation of a character in a `String` or in `Char lists`. This forces the creation of a new representation for this type so it can be correctly translated to from and to **edn**.

### Arbitrary Precision `Integer` and `Float`

The Erlang VM (EVM) only provides arbitrary precision integer so all integers will have this and the `N` modifier will be ignored when present.

On the other hand native arbitrary precision floating point numbers are not provided by the EVM so all values of type `float` will be represented according to what the EVM supports.

### `Keyword` and `Symbol` Representation

The decision to translate `keyword`s as `atom`s on the EVM comes form the common use these two data type are given. It might get awkward really quickly using a new `ExEdn.Symbol` struct as the representation for **edn**'s `symbol`s so this might change.

### `vector`

There is no constant lookup or nearly constant indexed data structure like **edn**'s `vector` other than the `:array` data structure implemented in one of Erlang's standard library modules. Until there is a better implementation for this `ExEdn` will use the [`Array`](https://github.com/takscape/elixir-array), an Elixir wrapper library for Erlang's array.

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