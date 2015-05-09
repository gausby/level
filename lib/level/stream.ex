defmodule Level.Stream do
	@moduldoc """
  Implements various stream operations
  """
	alias Level.Iterator

	@doc """
  Creates a stream from a open database connection.
  """
  def create(%Level{status: :open} = connection, opts \\ []) do
    Stream.resource(
      fn -> {:first, Iterator.create(connection, opts)} end,
      fn({status, iterator_ref}) ->
        case Iterator.move(iterator_ref, status) do
          {:ok, key, value} ->
						{[{key, value}], {:prefetch, iterator_ref}}
          {:ok, key} ->
						{[key], {:prefetch, iterator_ref}}
          _ ->
						{:halt, {:halted, iterator_ref}}
				end
      end,
      fn {_, iterator_ref} -> Iterator.close(iterator_ref) end
    )
  end

	@doc """
  Creates a stream from a open database connection which will stream the key and
  values, or keys, in a given key range.

  If no end-point is set it will stream everyting that begins with the start` value.
  """
	def range(%Level{status: :open} = connection, start, stop \\ nil, opts \\ []) when is_binary(start) do
		unless stop, do: stop = "#{start}\xff"
    Stream.resource(
      fn -> {start, Iterator.create(connection, opts)} end,
      fn({status, iterator_ref}) ->
        case Iterator.move(iterator_ref, status) do
          {:ok, key, value} when key <= stop ->
						{[{key, value}], {:prefetch, iterator_ref}}
          {:ok, key} when key <= stop ->
						{[key], {:prefetch, iterator_ref}}
          _ ->
						{:halt, {:halted, iterator_ref}}
				end
      end,
      fn {_, iterator_ref} -> Iterator.close(iterator_ref) end
    )
	end

end
