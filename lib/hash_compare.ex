defmodule HashCompare do
  @moduledoc """
  `HashCompare` compares two hashes (maps) or lists and reports their differences if any
  """

  defmodule Pos do
    @moduledoc """
    `Pos` holds all the positions for reporting where the differences are and stops at max depth
    """
    defstruct depth: 0, max_depth: 100, count: 0

    @spec bump_depth(%__MODULE__{}) :: %__MODULE__{}
    def bump_depth(%__MODULE__{depth: depth} = pos) do
      %Pos{pos | depth: depth + 1, count: 0}
    end

    @spec bump_count(%__MODULE__{}) :: %__MODULE__{}
    def bump_count(%__MODULE__{count: count} = pos) do
      %Pos{pos | count: count + 1}
    end
  end

  @spec compare_hash(map() | list(), map() | list(), integer()) :: binary()
  def compare_hash(hash1, hash2, max_depth \\ 100) do
    display_text = compare(hash1, hash2, %Pos{max_depth: max_depth}) |> :erlang.iolist_to_binary()

    case display_text do
      "" -> "Matching hashes"
      other -> other
    end
  end

  @spec compare(map() | list(), map() | list(), %Pos{}) :: list()

  # Max depth reached
  def compare(_, _, %Pos{depth: depth, max_depth: depth}) do
    []
  end

  # If it's a map turn it into a list
  def compare(hash1, hash2, pos) when is_map(hash1) and is_map(hash2) do
    compare(hash1 |> Map.to_list(), hash2 |> Map.to_list(), pos)
  end

  # If head is a map or list run compare on that
  def compare([h1 | t1], [h2 | t2], pos)
      when (is_map(h1) and is_map(h2)) or (is_list(h1) and is_list(h2)) do
    [compare(h1, h2, Pos.bump_depth(pos)) | compare(t1, t2, Pos.bump_count(pos))]
  end

  # Keys are the same
  def compare([{k, v1} | t1], [{k, v2} | t2], pos) do
    diffs =
      cond do
        # If value is a map or list run compare on that
        (is_map(v1) and is_map(v2)) or (is_list(v1) and is_list(v2)) ->
          compare(v1, v2, Pos.bump_depth(pos))

        # These match so just return nothing
        v1 == v2 ->
          []

        # Otherwise they don't match so add this message
        true ->
          [
            "Depth #{pos.depth}, position #{pos.count} difference on key: #{inspect(k)} #{inspect([v1, v2])} \n"
          ]
      end

    [diffs | compare(t1, t2, Pos.bump_count(pos))]
  end

  # Keys are different values are the same
  def compare([{k1, v} | t1], [{k2, v} | t2], pos) do
    [
      ["Depth #{pos.depth}, position #{pos.count} different keys: #{inspect([k1, k2])}} \n"]
      | compare(t1, t2, Pos.bump_count(pos))
    ]
  end

  # Keys and values different
  def compare([{k1, v1} | t1], [{k2, v2} | t2], pos)
      when (is_map(v1) and is_map(v2)) or (is_list(v1) and is_list(v2)) do
    [
      ["Depth #{pos.depth}, position #{pos.count} different keys: #{inspect([k1, k2])}} \n"],
      compare(t1, t2, Pos.bump_count(pos)) | compare(v1, v2, Pos.bump_depth(pos))
    ]
  end

  # List with matching heads
  def compare([h | t1], [h | t2], pos) do
    compare(t1, t2, Pos.bump_count(pos))
  end

  # Look for mismatched lists which have an extra or missing item
  def compare([h1 | t1] = list1, [h2 | t2] = list2, pos) do
    t1_index = Enum.find_index(list2, &(&1 == h1))
    t2_index = Enum.find_index(list1, &(&1 == h2))

    cond do
      not is_nil(t1_index) ->
        {skip, new_t2} = Enum.split(list2, t1_index)

        [
          ["Depth #{pos.depth}, position #{pos.count} hash 2 extra #{inspect(skip)} \n"]
          | compare(list1, new_t2, Pos.bump_count(pos))
        ]

      not is_nil(t2_index) ->
        {skip, new_t1} = Enum.split(list1, t2_index)

        [
          ["Depth #{pos.depth}, position #{pos.count} hash 2 extra #{inspect(skip)} \n"]
          | compare(new_t1, list2, Pos.bump_count(pos))
        ]

      true ->
        [
          ["Depth #{pos.depth}, position #{pos.count} difference #{inspect([h1, h2])} \n"]
          | compare(t1, t2, Pos.bump_count(pos))
        ]
    end
  end

  # Job's done
  def compare([], [], _pos) do
    []
  end

  # Leftover items in list2
  def compare([], list2, pos) do
    ["Depth #{pos.depth}, position #{pos.count} hash 2 extra #{inspect(list2)} \n"]
  end

  # Leftover items in list1
  def compare(list1, [], pos) do
    ["Depth #{pos.depth}, position #{pos.count} hash 1 extra #{inspect(list1)} \n"]
  end
end
