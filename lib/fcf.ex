defmodule FCF do
  def throttle(name) do
    Throttlex.Server.auto_throttle(name)
  end
  def dbg(on,s) do
 	if on do
 		IO.puts s
 	end 
  end
  def run(module,fun,args,options // []) do
    #@doc """
    #options
      #force: in [true,false}
      #throttle: throttle_name
    #"""
    force = Keyword.get(options,:force,false)
    on = Keyword.get(options,:debug,false)
    args = "#{inspect module}#{inspect fun}#{inspect args}"
    dbg on, "FCF.run: args: #{args}"
    hash = :erlang.phash2(args,4294967296)
    case has(hash) do
      :false -> 
        dbg on, "FCF.run: no cache, getting data: #{inspect hash}"
        case Keyword.get(options,:throttle) do
          nil -> nil
          name -> throttle(name)
        end
        res = apply(module,fun,args)
        store(res,hash,options)
      res when force ->   
        dbg on, "FCF.run: forced cache flush, getting data: #{inspect hash}"
        res = apply(module,fun,args)
        store(res,hash,options)
      res -> 
        dbg on, "FCF.run: found result in cache: #{inspect hash}"
        res
    end
    res
  end
  def flush_all do
 		:os.cmd('rm -rf cache/*') 
  end
  def has(hash) do
    file_name = "cache/#{hash}"
    case File.exists?(file_name) do
      true -> 
        {:ok,res} = File.read(file_name)
        :erlang.binary_to_term(res)
      false -> :false
    end
  end
  def store(res,hash,options) do
    res = :erlang.term_to_binary(res)
    #IO.puts "FCF store #{inspect res} #{inspect hash} "
    file_name = "cache/#{hash}"
    File.write(file_name,res)
  end
end
