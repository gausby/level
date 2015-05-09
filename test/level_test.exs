defmodule LevelTest do
  use ExUnit.Case
	
	setup do
    File.rm_rf "/tmp/level/test"
		File.mkdir "/tmp/level/"
    db = Level.create!("/tmp/level/test")
    {:ok, db: db}
  end

  test "create", %{db: db} do
		assert db == %Level{name: "/tmp/level/test", status: :open, ref: ""}
  end

  test "close", %{db: db} do
		assert Level.close(db) == {:ok, %Level{name: "/tmp/level/test", ref: nil, status: :closed}}
  end

  test "get", %{db: db} do
		Level.put(db, "key", "value")
		assert Level.get(db, "key") == "value"
		assert Level.get(db, "non_existent") == nil
		assert Level.get(db, "non_existent_with_default", "default") == "default"
  end

  test "delete", %{db: db} do
		Level.put(db, "key", "value")
		Level.delete(db, "key")
		assert Level.get(db, "key") == nil
	end
	
  test "batch operations", %{db: db} do
		Level.write(db, [{:put, "foo", "1"}, {:put, "bar", "2"}, {:put, "baz", "3"}, {:delete, "baz"}])
		assert Level.get(db, "foo") == "1"
		assert Level.get(db, "bar") == "2"
		assert Level.get(db, "baz") == nil
  end

	test "empty", %{db: db} do
		assert Level.is_empty?(db) == true
		Level.put(db, "key", "value")
		assert Level.is_empty?(db) == false
		Level.delete(db, "key")
		assert Level.is_empty?(db) == true
	end

	test "destroy", %{db: db} do
		assert Level.destroy(db) == %Level{db | ref: nil, status: :destroyed}
	end
		
	test "destroy already closed", %{db: db} do
		db = Level.close!(db)
	  assert Level.destroy(db) == %Level{db | status: :destroyed}
	end

	test "repair", %{db: db} do
		assert Level.repair(db) == %Level{db | ref: nil, status: :closed}
	end

  test "stream", %{db: db} do
		# fails for some reason with more than one element, works fine in iex.
		# I guess it is because of async operations in iterator_next
		Level.write(db, [{:put, "foo", "1"}])
		assert Level.stream(db) |> Enum.to_list == [{"foo", "1"}]
	end

  test "stream keys", %{db: db} do
		# fails for some reason with more than one element, works fine in iex.
		# I guess it is because of async operations in iterator_next
		Level.put(db, "foo", "1")
		assert Level.stream(db, [keys_only: true]) |> Enum.to_list == ["foo"]
	end


	test "collectable", %{db: db} do
		Enum.into([{"foo", "1"}, {"bar", "2"}, {"baz", "3"}], db)
		assert Level.get(db, "foo") == "1"
		assert Level.get(db, "baz") == "3"
	end
end
