# FCF

*** File Cache for Functions

This is a simple elixir library to enable you to cache long running functions, or network service calls to the file system for testing or other purposes.  This uses term_to_binary and I don't know if it will work with records, feel free to let me know.

General usage is: FCF.run(module,function,[args],[options])


```elixir

# run a function
FCF.run(Enum,:count,[[1,2,3]])

# 2nd run is from the disk, check ./cache
FCF.run(Enum,:count,[[1,2,3]])

# force flush of value
FCF.run(Enum,:count,[[1,2,3]],[force: true])

# remove all cache
FCF.flush_all

```
