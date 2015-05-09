defmodule Level do
	defstruct name: nil, ref: nil, status: nil

	@doc """
  Create a new LevelDB and open a connection
  """
	def create(name, opts \\ []) when is_binary(name),
	  do: open(name, Keyword.merge(opts, [create_if_missing: true]))
	
	def create!(name, opts \\ []) when is_binary(name),
	  do: open!(name, Keyword.merge(opts, [create_if_missing: true]))

	@doc """
  Opens a connection to a data store
  """
  def open(name, opts \\ []) when is_binary(name) do
		case :eleveldb.open(String.to_char_list(name), opts) do
			{:ok, ref} ->
				{:ok, %__MODULE__{name: name, ref: ref, status: :open}}
			err ->
				err
    end
  end
	
  def open!(name, opts \\ []) when is_binary(name) do
		{:ok, connection} = open(name, opts)
    connection
  end

	@doc """
  Close the connection to a data store
  """
	def close(%__MODULE__{ref: db, status: :open} = connection) do
		case :eleveldb.close(db) do
			:ok -> {:ok, %__MODULE__{connection | ref: nil, status: :closed}}
			err -> err
		end
	end

	def close!(%__MODULE__{status: :open} = connection) do
	  {:ok, connection} = close(connection)
		connection
	end

	def get(connection, key, default \\ nil, opts \\ [])
	def get(%__MODULE__{ref: db, status: :open}, key, default, opts) do
		case :eleveldb.get(db, key, opts) do
			{:ok, value} -> value
			:not_found -> default
		end
	end

	def stream(%__MODULE__{status: :open} = connection, opts \\ []),
		do: Level.Stream.create(connection, opts)

	def range(%__MODULE__{status: :open} = connection, start, stop \\ nil, opts \\ []),
		do: Level.Stream.range(connection, start, stop, opts)

	def write(%__MODULE__{ref: db, status: :open}, updates, opts \\ []) when is_list(updates),
		do: :eleveldb.write(db, updates, opts)
		
	def put(%__MODULE__{ref: db, status: :open}, key, value, opts \\ []),
	  do: :eleveldb.write(db, [{:put, key, value}], opts)
		
	def delete(%__MODULE__{ref: db, status: :open}, key, opts \\ []) when is_binary(key),
		do: :eleveldb.write(db, [delete: key], opts)

	def is_empty?(%__MODULE__{ref: db}),
		do: :eleveldb.is_empty(db)

	@doc """
  Destroy and delete a data store. This can not be undone.

  Will close the connection if it is open.
  """
	def destroy(connection, opts \\ [])
	def destroy(%__MODULE__{status: :open} = connection, opts),
		do: connection |> close! |> destroy(opts)
	def destroy(%__MODULE__{name: name, status: :closed} = connection, opts) do
	  :ok = :eleveldb.destroy(String.to_char_list(name), opts)
		%__MODULE__{connection | status: :destroyed}
	end

	@doc """
  Repair a data store. Will close the connection if the input is a connection.
  """
	def repair(connection, opts \\ [])
  def repair(%__MODULE__{status: :open} = connection, opts),
		do: connection |> close! |> repair(opts)
	def repair(%__MODULE__{name: name, status: :closed} = connection, opts) do
	  :ok = :eleveldb.repair(String.to_char_list(name), opts)
		connection
	end

end

defimpl Collectable, for: Level do
	def into(%Level{status: :open} = connection) do
		{connection, fn
			_, {:cont, {key, value}} -> :eleveldb.put(connection.ref, key, value, [])
			_, {:cont, key} when is_binary(key) -> :eleveldb.put(connection.ref, key, key, [])
			_, :done -> connection
			_, :halt -> :ok
		end}
	end
end
