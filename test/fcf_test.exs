Code.require_file "test_helper.exs", __DIR__
defmodule Tst do
  def boink do
    {1,2,3}
  end
  def wait(_) do
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
  test "handles an error" do
  	# TODO: get this working
 	nxdomain = "octcobucks.com"
 	res = FCF.run(:inet,:gethostbyaddr,[nxdomain],throttle: :w1s)
  end
  test "bypasses cache when it should" do
  	IO.puts "testing uncached"
  	t1 = :erlang.now
 		FCF.run(Tst,:wait,[:foo],debug: true)
 		t2 = :erlang.now
 		assert(:timer.now_diff(t2,t1) >= 200000)
 		IO.puts "testing cached"	
 		t1 = :erlang.now
 		FCF.run(Tst,:wait,[:foo],debug: true)
 		t2 = :erlang.now
 		assert(:timer.now_diff(t2,t1) < 200000)
 		IO.puts "testing force cached"
 		t1 = :erlang.now
 		FCF.run(Tst,:wait,[:foo],[debug: true,force: true])
 		t2 = :erlang.now
 		assert(:timer.now_diff(t2,t1) >= 200000)
  end
  test "flushes module+fun directory" do
 		md5 = FCF.md5("#{Tst}#{:wait}" )
 		IO.puts "trying to flush: #{md5}"
 		FCF.run(Tst,:wait,[:foo]) 
 		assert(File.exists?("cache/#{md5}"))
 		FCF.flush(md5)
 		assert(File.exists?("cache/#{md5}") == false)
  end
  test "throttles" do
    res = FCF.run(Tst,:boink,[],[debug: true, throttle: :w1s])
  end
end
