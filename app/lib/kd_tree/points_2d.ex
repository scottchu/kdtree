defmodule KDTree.Points2D do
  alias KDTree.Point2D

  @spec load(points :: list(Point2D.json())) :: list(Point2D.t())
  def load(points) do
    points
    |> Enum.map(&Point2D.load/1)
  end

  @dimensions 2
  defp axis(depth) do
    depth
    |> rem(@dimensions)
    |> case do
      0 -> :x
      1 -> :y
    end
  end

  def sort(points, depth) do
    dimension = axis(depth)

    points
    |> Enum.sort_by(&(Point2D.value(&1, dimension)))
  end

  def split(points) do
    _split(points, - midpoint(points))
  end

  defp _split(points, dm, acc \\ {nil, [], []})
  defp _split([], _dm, {middle, left, right}), do: {middle, left, right}
  defp _split([point | points], dm, {middle, left, right}) when dm < 0,
    do: _split(points, dm + 1, {middle, [point | left], right})
  defp _split([point | points], dm, {middle, left, right}) when dm > 0,
    do: _split(points, dm + 1, {middle, left, [point | right]})
  defp _split([point | points], dm, {_, left, right}) when dm == 0,
    do: _split(points, dm + 1, {point, left, right})

  defp midpoint(points), do: ceil(length(points) / 2) - 1

  def empty([]), do: true
  def empty(_), do: false
end
