defmodule ExEdn.LexerTest do
  use ExUnit.Case
  alias ExEdn.Lexer
  alias ExEdn.Exception, as: Ex

  test "Whitespace" do
    assert Lexer.tokenize(",,,  ") == []
    assert Lexer.tokenize(" \n \t, \r") == []
  end

  test "nil, true, false" do
    assert Lexer.tokenize("nil") == [token(:nil, "nil")]
    assert Lexer.tokenize(" nil ") == [token(:nil, "nil")]
    assert Lexer.tokenize("true") == [token(:true, "true")]
    assert Lexer.tokenize(" true ") == [token(:true, "true")]
    assert Lexer.tokenize("false") == [token(:false, "false")]
    assert Lexer.tokenize(" false ") == [token(:false, "false")]

    assert List.first(Lexer.tokenize(" nil{ ")) == token(:nil, "nil")
    assert List.first(Lexer.tokenize(" nilo ")) == token(:symbol, "nilo")

    assert List.first(Lexer.tokenize(" true} ")) == token(:true, "true")
    assert List.first(Lexer.tokenize(" truedetective ")) == token(:symbol, "truedetective")

    assert List.first(Lexer.tokenize(" false{ ")) == token(:false, "false")
    assert List.first(Lexer.tokenize(" falsette ")) == token(:symbol, "falsette")
  end

  test "String" do
    assert Lexer.tokenize(" \"this is a string\" ") == [token(:string, "this is a string")]
    assert Lexer.tokenize(" \"this is a \\\" string\" ") == [token(:string, "this is a \" string")]
    assert_raise Ex.UnfinishedTokenError, fn ->
      Lexer.tokenize(" \"this is an unfinished string ")
    end
    assert_raise Ex.UnfinishedTokenError, fn ->
      Lexer.tokenize(" \"this is an unfinished string\\\"")
    end
  end

  test "Character" do
    assert Lexer.tokenize(" \\t ") == [token(:character, "t")]
    assert Lexer.tokenize(" \\r,, ") == [token(:character, "r")]
  end

  test "Keyword" do
    assert Lexer.tokenize(" :a-keyword ") == [token(:keyword, "a-keyword")]
    assert Lexer.tokenize(":a-keyword") == [token(:keyword, "a-keyword")]
    assert Lexer.tokenize(" :question? ") == [token(:keyword, "question?")]
    assert Lexer.tokenize(":question?{") == [token(:keyword, "question?"), token(:curly_open, "{")]
    assert Lexer.tokenize(":k?+._-!7><$&=*") == [token(:keyword, "k?+._-!7><$&=*")]

    assert_raise Ex.UnexpectedInputError, fn ->
      Lexer.tokenize(" :question?\\")
    end
  end

  test "Symbol" do
    assert Lexer.tokenize(" a-keyword ") == [token(:symbol, "a-keyword")]
    assert Lexer.tokenize("a-keyword") == [token(:symbol, "a-keyword")]
    assert Lexer.tokenize(" question? ") == [token(:symbol, "question?")]
    assert Lexer.tokenize("question?{") == [token(:symbol, "question?"), token(:curly_open, "{")]
    assert Lexer.tokenize("k?+._-!7><$&=*") == [token(:symbol, "k?+._-!7><$&=*")]
    assert Lexer.tokenize("ns/name") == [token(:symbol, "ns/name")]

    assert_raise Ex.UnexpectedInputError, fn ->
      Lexer.tokenize(" question?\\")
    end
    assert_raise Ex.UnexpectedInputError, fn ->
      Lexer.tokenize("ns/name/ss")
    end
  end

  test "Integer" do
    assert Lexer.tokenize("1234") == [token(:integer, "1234")]
    assert Lexer.tokenize(" 1234 ") == [token(:integer, "1234")]
    assert Lexer.tokenize("1234N") == [token(:integer, "1234N")]
    assert Lexer.tokenize("1234N{") == [token(:integer, "1234N"), token(:curly_open, "{")]

    assert_raise Ex.UnexpectedInputError, fn ->
      assert Lexer.tokenize("1234a")
    end
  end

  test "Float" do
    assert Lexer.tokenize("1234.12") == [token(:float, "1234.12")]
    assert Lexer.tokenize(" 1234.12 ") == [token(:float, "1234.12")]
    assert Lexer.tokenize("1234M") == [token(:float, "1234M")]
    assert Lexer.tokenize("1234M{") == [token(:float, "1234M"), token(:curly_open, "{")]

    assert Lexer.tokenize("1234E12") == [token(:float, "1234E12")]
    assert Lexer.tokenize("1234E-12") == [token(:float, "1234E-12")]
    assert Lexer.tokenize("1234E+12") == [token(:float, "1234E+12")]

    assert Lexer.tokenize("1234e12") == [token(:float, "1234e12")]
    assert Lexer.tokenize("1234e-12") == [token(:float, "1234e-12")]
    assert Lexer.tokenize("1234e+12") == [token(:float, "1234e+12")]

    assert_raise Ex.UnexpectedInputError, fn ->
      assert Lexer.tokenize("1234.a")
    end
    assert_raise Ex.UnexpectedInputError, fn ->
      assert Lexer.tokenize("1234.121a ")
    end
    assert_raise Ex.UnexpectedInputError, fn ->
      assert Lexer.tokenize("1234E0a1")
    end
    assert_raise Ex.UnfinishedTokenError, fn ->
      Lexer.tokenize("1234E")
    end
    assert_raise Ex.UnfinishedTokenError, fn ->
      Lexer.tokenize("1234.")
    end
    assert_raise Ex.UnfinishedTokenError, fn ->
      Lexer.tokenize("1234. :kw")
    end
  end

  test "Delimiters" do
    assert Lexer.tokenize("{[#\{}]} )()") == [token(:curly_open, "{"),
                                              token(:bracket_open, "["),
                                              token(:set_open, "#\{"),
                                              token(:curly_close, "}"),
                                              token(:bracket_close, "]"),
                                              token(:curly_close, "}"),
                                              token(:paren_close, ")"),
                                              token(:paren_open, "("),
                                              token(:paren_close, ")")]
  end

  test "Discard" do
    assert Lexer.tokenize("#_ ") == [token(:discard, "#_")]
    assert Lexer.tokenize("1 #_ :kw") == [token(:integer, "1"),
                                          token(:discard, "#_"),
                                          token(:keyword, "kw")]
  end

  test "Tag" do
    assert Lexer.tokenize("#ns/name") == [token(:tag, "ns/name")]
    assert Lexer.tokenize("#whatever") == [token(:tag, "whatever")]
    assert Lexer.tokenize(" #whatever :kw") == [token(:tag, "whatever"),
                                                token(:keyword, "kw")]
  end

  test "Comment" do
    assert Lexer.tokenize("1 ;; hello") == [token(:integer, "1"),
                                            token(:comment, " hello")]
    assert Lexer.tokenize("1 ;; hello\n\r") == [token(:integer, "1"),
                                                token(:comment, " hello")]
    assert Lexer.tokenize("1 ;; hello\n\r bla") == [token(:integer, "1"),
                                                  token(:comment, " hello"),
                                                  token(:symbol, "bla")]
  end


  defp token(type, value) do
    %Lexer.Token{type: type, value: value}
  end
end
