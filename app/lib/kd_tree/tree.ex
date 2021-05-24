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
  defp _build([], _implementation, _depth), do: nil
  defp _build(points, implementation, depth) do
    {point, left, right} = points
    |> implementation.sort(depth)
    |> implementation.split()

    left_tree = _build(left, implementation, depth + 1)
    right_tree = _build(right, implementation, depth + 1)

    create(point, left_tree, right_tree, depth)
  end

  def closest(tree, point, implementation) do
    _closest(tree, point, implementation)
  end

  defp _closest(tree, point, implementation, best \\ nil)
  defp _closest(nil, _point, _implementation, best), do: best
  defp _closest(
    %__MODULE__{point: root, depth: depth} = tree,
    point,
    implementation,
    best) do
    next_best = pick_closer(point, root, best, implementation)
    {next_branch, opposite_branch} = branch(tree, point, implementation)

    new_best = pick_closer(point,
      _closest(next_branch, point, implementation, next_best),
      root,
      implementation)

    new_best = if implementation.distance(point, new_best) > implementation.distance(point, root, depth) do
      pick_closer(point,
      _closest(opposite_branch, point, implementation, new_best),
      root,
      implementation)
    else
      new_best
    end
  end

  defp pick_closer(_base, nil, rhs, _implementation), do: rhs
  defp pick_closer(_base, lhs, nil, _implementation), do: lhs
  defp pick_closer(base, lhs, rhs, implementation) do
    d1 = implementation.distance(base, lhs)
    d2 = implementation.distance(base, rhs)
    case d1 > d2 do
      true -> rhs
      false -> lhs
    end
  end

  defp branch(%__MODULE__{point: root, depth: depth, left: left, right: right}, point, implementation) do
    if implementation.lt(point, root, depth) do
      {left, right}
    else
      {right, left}
    end
  end

end
