Code.require_file "test_helper.exs", __DIR__
defmodule Tst do
  def boink do
    {1,2,3}
  end
  def wait do
 		:timer.sleep(200) 
  end
end
defmodule FcfTest do
  use ExUnit.Case
  setup_all do
    FCF.flush_all
    :ok
  end
  teardown_all do
    FCF.flush_all
    :ok
  end
  test "writes to a file" do
    res = FCF.run(Tst,:boink,[]) 
    assert(res = {1,2,3})
  end
  test "bypasses cache when it should" do
  	t1 = :erlang.now
 		FCF.run(Tst,:wait,[])
 		t2 = :erlang.now
 		assert(:timer.now_diff(t2,t1) >= 200000)
 		t1 = :erlang.now
 		FCF.run(Tst,:wait,[])
 		t2 = :erlang.now
 		assert(:timer.now_diff(t2,t1) < 200000)
 		t1 = :erlang.now
 		FCF.run(Tst,:wait,[],[force: true])
 		t2 = :erlang.now
 		assert(:timer.now_diff(t2,t1) >= 200000)
  end
end
