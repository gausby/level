defmodule Level.Iterator do
	@moduledoc """
  An iterator can be used to traverse the data store. It can be created using `Level.Iterator.create/2` and the 
  `Level.Iterator.move/2` function can be used closed again using the `close/1` function.
  """

	defstruct ref: nil, status: :closed
	
  @doc """
  Opens and returns an interator which can be used to traverse the
  data store using the `Level.Iterator.move/2` function. It can be
  closed again using the `close/1` function.
  """
	def create(%Level{ref: db, status: :open}, opts \\ []) do
		if (opts[:keys_only]) do
			opts = Keyword.delete(opts, :keys_only)
			{:ok, iterator_ref} = :eleveldb.iterator(db, opts, :keys_only)
		else
			{:ok, iterator_ref} = :eleveldb.iterator(db, opts)
		end
		%__MODULE__{ref: iterator_ref, status: :open}
	end

	@doc """
  Move the pointer in a data store using the following actions:

    * :first - move to the first element
    * :next - move forward
    * :prev - move backwards
    * :last - move to last
    * :prefetch

  It is also posible to give it a binary in which case it will move
  the pointer to the closest key.

  Every operation will return `{:ok, key, value}`, or `{:ok, key}` if the
  """
	def move(%__MODULE__{ref: iterator_ref, status: :open}, action),
		do: :eleveldb.iterator_move(iterator_ref, action)

  @doc """
  Close the iterator
  """
	def close(%__MODULE__{ref: iterator_ref, status: :open}) do
		:ok = :eleveldb.iterator_close(iterator_ref)
		%__MODULE__{ref: iterator_ref, status: :closed}
	end

end
