defmodule ExEdnTest do
  use ExUnit.Case
  import ExEdn

  test "Literals" do
    assert decode!("nil") == nil
    assert decode!("true") == true
    assert decode!("false") == false

    assert decode!("42") == 42
    assert decode!("42N") == 42

    assert decode!("42.0") == 42.0
    assert decode!("42M") == 42.0
    assert decode!("42.0e3") == 42000.0
  end
end
