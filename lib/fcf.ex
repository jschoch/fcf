defmodule FCF do
  def throttle(name) do
    Throttlex.Server.auto_throttle(name)
  end
  def run(module,fun,args,options // []) do
    #@doc """
    #options
      #force: in [true,false}
      #throttle: throttle_name
    #"""
    hash = :erlang.phash2("#{inspect module}#{inspect fun}#{inspect args}",4294967296)
    case has(hash) do
      :false -> 
        #IO.puts "no cache, getting data: #{inspect hash}"
        case Keyword.get(options,:throttle) do
          nil -> nil
          name -> throttle(name)
        end
        res = apply(module,fun,args)
        store(res,hash,options)
      res when options != [] ->   
        #IO.puts "forced cache flush, getting data: #{inspect hash}"
        res = apply(module,fun,args)
        store(res,hash,options)
      res -> 
        #IO.puts "found result in cache: #{inspect hash}"
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
