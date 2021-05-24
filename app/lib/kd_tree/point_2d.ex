defmodule KDTree.Point2D do

  @enforce_keys [:x, :y, :id]
  defstruct [:x, :y, :id]

  @type t() :: %__MODULE__{
    x: integer(),
    y: integer(),
    id: binary()
  }

  @type json() :: %{
    x: integer(),
    y: integer(),
    id: binary()
  }

  @spec load(json: json()) :: t()
  def load(%{x: x, y: y, id: id}) do
    create(x, y, id)
  end

  @spec create(x :: integer(), y :: integer(), id :: binary()) :: t()
  def create(x, y, id) do
    %__MODULE__{x: x, y: y, id: id}
  end

  def value(%__MODULE__{x: x}, :x), do: x
  def value(%__MODULE__{y: y}, :y), do: y
end
