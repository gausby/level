Level for Elixir
================

Level for Elixir implements various helper functions and data types for working with Googles Level data store.

The project is implemented using [Basho's eleveldb](https://github.com/basho/eleveldb) level data bindings, but its interface varies a bit. If you are looking for a minimal eLevelDb Elixir wrapper which is more true to eleveldb you should check out [ExLevelDb](https://github.com/skovsgaard/exleveldb) by [Jonas Skovsgaard](https://github.com/skovsgaard/).


Installation
------------
The project is on hex.pm. Add it to your dependencies as you would with any other hex-package.

The eleveldb dependency require you to run `mix do deps.get, deps.compile` because it is not a hex-package.


Examples
--------
Create a data store with a ton of words.

```elixir
words = Level.create!("/tmp/words")

Level.get(words, "test")

File.stream!("/usr/share/dict/words")
|> Stream.map(&String.strip/1)
|> Enum.into(words)

Level.get(words, "test")
```

Let us find the palindromes in the words.

```elixir
palindromes = Level.stream(words, [keys_only: true])
|> Stream.filter(&(&1 == String.reverse(&1)))
|> Enum.into([])
```

Now let us try to find the longest word between a and g.

```elixir
longest_word_in_range = Level.range(words, "a", "f\xff", [keys_only: true])
|> Enum.reduce("", fn(word, acc) -> if String.length(acc) <= String.length(word), do: word, else: acc end)
```

License
-------
The MIT License (MIT)

Copyright (c) 2015 Martin Gausby

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
