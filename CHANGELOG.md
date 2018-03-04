# Change Log

## [2.0.0](https://github.com/jfacorro/eden/tree/2.0.0)

[Full Changelog](https://github.com/jfacorro/eden/compare/1.0.2...2.0.0)

**Merged pull requests:**

- Migrated to Elixir 1.5 and Timex 3.1 [\#37](https://github.com/jfacorro/Eden/pull/37) ([f34nk](https://github.com/f34nk))

## [1.0.2](https://github.com/jfacorro/eden/tree/1.0.2) (2017-06-14)
[Full Changelog](https://github.com/jfacorro/eden/compare/1.0.1...1.0.2)

**Fixed bugs:**

- The input ":" is decoded as an Elixir atom instead of generating an error [\#22](https://github.com/jfacorro/Eden/issues/22)

**Merged pull requests:**

- \[Fixes \#22\] Throw exception when trying to parse a single colon [\#36](https://github.com/jfacorro/Eden/pull/36) ([jfacorro](https://github.com/jfacorro))

## [1.0.1](https://github.com/jfacorro/eden/tree/1.0.1) (2017-06-14)
[Full Changelog](https://github.com/jfacorro/eden/compare/1.0.0...1.0.1)

**Closed issues:**

- Could not parse file [\#32](https://github.com/jfacorro/Eden/issues/32)

**Merged pull requests:**

- \[\#32\] Specify utf8 encoding for all binaries built in lexer [\#35](https://github.com/jfacorro/Eden/pull/35) ([jfacorro](https://github.com/jfacorro))
- Bump version [\#34](https://github.com/jfacorro/Eden/pull/34) ([jfacorro](https://github.com/jfacorro))
- \[Fixes \#32\] Specify utf8 enconding when buliding single char binaries in lexer [\#33](https://github.com/jfacorro/Eden/pull/33) ([jfacorro](https://github.com/jfacorro))

## [1.0.0](https://github.com/jfacorro/eden/tree/1.0.0) (2016-09-16)
[Full Changelog](https://github.com/jfacorro/eden/compare/0.1.3...1.0.0)

**Implemented enhancements:**

- Doesn't compile for Elixir 1.3.2 [\#30](https://github.com/jfacorro/Eden/issues/30)

**Merged pull requests:**

- \[Closes \#30\] Fix warning and replaced Access protocol for behaviour [\#31](https://github.com/jfacorro/Eden/pull/31) ([jfacorro](https://github.com/jfacorro))
- Force build [\#28](https://github.com/jfacorro/Eden/pull/28) ([jfacorro](https://github.com/jfacorro))

## [0.1.3](https://github.com/jfacorro/eden/tree/0.1.3) (2015-06-13)
[Full Changelog](https://github.com/jfacorro/eden/compare/0.1.2...0.1.3)

**Implemented enhancements:**

- Version bump 0.1.2 [\#18](https://github.com/jfacorro/Eden/issues/18)

**Closed issues:**

- Fix example in README.md and correct the Erlang OTP [\#25](https://github.com/jfacorro/Eden/issues/25)
- Upload generated docs to gh-pages branch  [\#23](https://github.com/jfacorro/Eden/issues/23)
- Rename project ExEdn to Eden [\#21](https://github.com/jfacorro/Eden/issues/21)
- Publish in Hex [\#17](https://github.com/jfacorro/Eden/issues/17)

**Merged pull requests:**

- Version bump to 0.1.3 [\#27](https://github.com/jfacorro/Eden/pull/27) ([jfacorro](https://github.com/jfacorro))
- \[Closes \#25\] Fix README add application deps [\#26](https://github.com/jfacorro/Eden/pull/26) ([jfacorro](https://github.com/jfacorro))
- \[\#21\] Rename from ExEdn to Eden [\#24](https://github.com/jfacorro/Eden/pull/24) ([jfacorro](https://github.com/jfacorro))
- \[Closes \#17\] Publish in hex.pm [\#20](https://github.com/jfacorro/Eden/pull/20) ([jfacorro](https://github.com/jfacorro))

## [0.1.2](https://github.com/jfacorro/eden/tree/0.1.2) (2015-06-13)
[Full Changelog](https://github.com/jfacorro/eden/compare/0.1.1...0.1.2)

**Closed issues:**

- More information for the Protocol.UndefinedError raised by ExEdn.Encode [\#14](https://github.com/jfacorro/Eden/issues/14)
- Docs and specs for almost everything [\#10](https://github.com/jfacorro/Eden/issues/10)

**Merged pull requests:**

- \[\#18\] Version bump 0.1.2 [\#19](https://github.com/jfacorro/Eden/pull/19) ([jfacorro](https://github.com/jfacorro))
- \[Closes \#10\] Docs and specs [\#16](https://github.com/jfacorro/Eden/pull/16) ([jfacorro](https://github.com/jfacorro))
- \[\#14\] Added more information to Protocol.UndefinedError [\#15](https://github.com/jfacorro/Eden/pull/15) ([jfacorro](https://github.com/jfacorro))

## [0.1.1](https://github.com/jfacorro/eden/tree/0.1.1) (2015-06-10)
[Full Changelog](https://github.com/jfacorro/eden/compare/0.1.0...0.1.1)

**Closed issues:**

- Add an Encode protocol implementation for Any [\#12](https://github.com/jfacorro/Eden/issues/12)

**Merged pull requests:**

- \[Closes \#12\] Encode protocol implementation for Any, but actually only for s… [\#13](https://github.com/jfacorro/Eden/pull/13) ([jfacorro](https://github.com/jfacorro))

## [0.1.0](https://github.com/jfacorro/eden/tree/0.1.0) (2015-06-10)
**Closed issues:**

- Elixir -\> edn [\#8](https://github.com/jfacorro/Eden/issues/8)
- edn \(parse tree\) -\> Elixir  [\#5](https://github.com/jfacorro/Eden/issues/5)
- Add line and column information to lexer [\#4](https://github.com/jfacorro/Eden/issues/4)
- Parser [\#2](https://github.com/jfacorro/Eden/issues/2)
- Lexer [\#1](https://github.com/jfacorro/Eden/issues/1)

**Merged pull requests:**

- \[Closes \#8\] Elixir -\> edn [\#11](https://github.com/jfacorro/Eden/pull/11) ([jfacorro](https://github.com/jfacorro))
- \[Closes \#5\] Elixir from parse tree [\#9](https://github.com/jfacorro/Eden/pull/9) ([jfacorro](https://github.com/jfacorro))
- \[Closes \#4\] Line and column information for tokens [\#7](https://github.com/jfacorro/Eden/pull/7) ([jfacorro](https://github.com/jfacorro))
- \[Closes \#2\] Parser [\#6](https://github.com/jfacorro/Eden/pull/6) ([jfacorro](https://github.com/jfacorro))
- \[\#1\] Lexer [\#3](https://github.com/jfacorro/Eden/pull/3) ([jfacorro](https://github.com/jfacorro))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
