defmodule KDTree.Tree do

  @enforce_keys [:point, :left, :right, :depth]
  defstruct [:point, :depth, left: nil, right: nil]

  @type t() :: %__MODULE__{
    point: Point.t(),
    left: t() | none(),
    right: t() | none(),
    depth: non_neg_integer()
  }

  @spec create(
    point :: term(),
    left :: t(),
    right :: t(),
    dpeth :: non_neg_integer()
  ) :: t()
  def create(point, left \\ nil, right \\ nil, depth \\ 0) do
    %__MODULE__{point: point, left: left, right: right, depth: depth}
  end

  @spec build(points :: list(term()), implementation :: module()) :: t()
  def build(points, implementation) do
    _build(points, implementation)
  end

  defp _build(points, implementation, depth \\ 0)
  defp _build([], _implementation, depth), do: nil
  defp _build(points, implementation, depth) do
    {point, left, right} = points
    |> implementation.sort(depth)
    |> implementation.split()

    left_tree = _build(left, implementation, depth + 1)
    right_tree = _build(right, implementation, depth + 1)

    create(point, left_tree, right_tree, depth)
  end

end
