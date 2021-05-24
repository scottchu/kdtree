defmodule KDTree do
  import SweetXml

  def run(svg_file \\ "/data/points2.svg") do
    {pivot, points} = svg_file
      |> KDTree.load()

    pivot = pivot
    |> KDTree.Point2D.load()

    tree = points
      |> KDTree.Points2D.load()
      |> KDTree.Tree.build(KDTree.Points2D)

      tree
    |> KDTree.Tree.closest(pivot, KDTree.Points2D)
  end

  def load(svg_file) do
    svg_file
    |> File.read()
    |> case do
      {:ok, file} -> file
      _ -> ""
    end
    |> load_circles()
  end

  def load_circles(xml) do
    pivot = xml
    |> xpath(~x"//svg/g/circle"l,
      y: ~x"./@cy"S,
      x: ~x"./@cx"S,
      id: ~x"./@id"S
    )
    |> IO.inspect()
    |> Enum.map(&transform/1)
    |> hd()

    points = xml
    |> xpath(~x"//svg/g/g/circle"l,
      y: ~x"./@cy"S,
      x: ~x"./@cx"S,
      id: ~x"./@id"S
    )

    |> Enum.map(&transform/1)

    {pivot, points}
  end

  def transform(%{x: x, y: y} = point) do
    %{point | x: String.to_float(x), y: String.to_float(y) }
  end

  def distance(%{x: x1, y: y1}, %{x: x2, y: y2}) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(:math.pow(dx, 2) + :math.pow(dy, 2))
  end

  def closest(points, new_point) do
    exhaustive(points, new_point)
  end

  def brutal(points, new_point) do
    points
    |> Enum.map(fn point ->
      point
      |> Map.put(:distance, distance(point, new_point))
    end)
    |> Enum.sort_by(&(Map.get(&1, :distance)))
    |> hd()
    |> IO.inspect()
  end

  def exhaustive(points, new_point, closest \\ nil)
  def exhaustive([], _new_point, %{point: point}), do: point
  def exhaustive([p | ps], new_point, nil) do
    exhaustive(ps, new_point, %{point: p, distance: distance(p, new_point)})
  end

  def exhaustive([p | ps], new_point, %{distance: closest_distance} = closest) do
    current_distance = distance(p, new_point)

    case current_distance > closest_distance do
      true -> exhaustive(ps, new_point, closest)
      _ -> exhaustive(ps, new_point, %{point: p, distance: current_distance})
    end
  end

  def build_tree(points, k) do
    _build_tree(points, k)
  end

  defp _build_tree(ps, k, depth \\ 0, tree \\ nil)
  defp _build_tree([], _k, depth, tree), do: tree
  defp _build_tree(ps, k, depth, tree) do
    axis = calc_axis(k, depth)

    sorted_points = sort(ps, axis)

    %{middle: m, left: l, right: r} = split(sorted_points)

    %{
      point: m,
      depth: depth,
      left: _build_tree(l, k, depth + 1) ,
      right: _build_tree(r, k, depth + 1) ,

    }
  end

  defp calc_axis(dimensions, depth) do
    case rem(depth, dimensions) do
      0 -> :x
      1 -> :y
    end
  end

  defp sort(points, axis) do
    points
    |> Enum.sort_by(&(&1[axis]))
  end

  def split(points) do
    _split(points, -mid_point(points))
  end

  def _split(points, dm, acc \\ %{middle: nil, left: [], right: []})
  def _split([], _dm, acc), do: acc
  def _split([p | ps], dm, %{left: left} = acc) when dm < 0 ,
    do: _split(ps, dm + 1, %{acc | left: [p | left]})
  def _split([p | ps], dm, %{right: right} = acc) when dm > 0,
    do: _split(ps, dm + 1, %{acc | right: [p | right]})
  def _split([p | ps], dm, acc) when dm == 0,
    do: _split(ps, dm + 1, %{acc | middle: p})

  defp mid_point(points), do: ceil(length(points) / 2) - 1

end
