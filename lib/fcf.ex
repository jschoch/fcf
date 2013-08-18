defmodule FCF do
  def throttle(name) do
    Throttlex.Server.auto_throttle(name)
  end
  def dbg(on,s) do
 	if on do
 		IO.puts s
 	end 
  end
  def md5(s) do
 		list_to_binary(Enum.map(bitstring_to_list(:crypto.md5(s)), fn(x) -> 
 			integer_to_binary(x, 16) 
 		end)) 
  end
  def run(module,fun,args,options // []) do
    #@doc """
    #options
      #force: in [true,false}
      #throttle: throttle_name
    #"""
    force = Keyword.get(options,:force,false)
    on = Keyword.get(options,:debug,false)
    args_string = "#{inspect args}"
    dbg on, "FCF.run: args_string: #{args_string}"
    arg_hash = md5(args_string)
    dir_hash = md5("#{module}#{fun}")
    case has(dir_hash,arg_hash) do
      :false -> 
        dbg on, "FCF.run: no cache, getting data: cache/#{dir_hash}/#{arg_hash}"
        case Keyword.get(options,:throttle) do
          nil -> nil
          name -> throttle(name)
        end
        res = apply(module,fun,args)
        store(res,dir_hash,arg_hash,options)
      res when force ->   
        dbg on, "FCF.run: forced cache flush, getting data: cache/#{dir_hash}/#{arg_hash}"
        res = apply(module,fun,args)
        store(res,dir_hash,arg_hash,options)
      res -> 
        dbg on, "FCF.run: found result in cache: cache/#{dir_hash}/#{arg_hash}"
        res
    end
    res
  end
  def flush_all do
 		#:os.cmd('rm -rf cache/*') 
 		File.rm_rf("cache")
  end
  def flush(dir_hash) do
  	#TODO; probable security issue here
  	File.rm_rf("cache/#{dir_hash}")
  end
  def flush(dir_hash,arg_hash) do
 		IO.puts "TODO flush/2" 
  end
  def has(hash) do
    file_name = "cache/#{hash}"
    IO.puts "has/1 checking #{file_name}"
    case File.exists?(file_name) do
      true -> 
        {:ok,res} = File.read(file_name)
        :erlang.binary_to_term(res)
      false -> :false
    end
  end
  def has(dir_hash, arg_hash) do
 		file_name = "#{dir_hash}/#{arg_hash}" 
 		has(file_name)
  end
  def store(res,dir_hash,arg_hash,options) do
  	on = Keyword.get(options,:debug,false)
    res = :erlang.term_to_binary(res)
    #IO.puts "FCF store #{inspect res} #{inspect hash} "
    unless File.exists?("cache") do
    	IO.puts "FCF making cached directory"
    	File.mkdir("cache")
    end
    unless File.exists?("cache/#{dir_hash}") do
   		File.mkdir("cache/#{dir_hash}")
    end
    file_name = "cache/#{dir_hash}/#{arg_hash}"
    dbg on, "FCF.store Writing file #{file_name}"
    File.write(file_name,res)
  end
end
