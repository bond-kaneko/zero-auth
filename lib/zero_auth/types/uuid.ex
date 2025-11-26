defmodule ZeroAuth.Types.UUID do
  @moduledoc """
  Custom UUID type for Ecto
  """

  use Ecto.Type

  def type, do: :binary_id

  def cast(value) when is_binary(value) do
    case Ecto.UUID.cast(value) do
      {:ok, uuid} -> {:ok, uuid}
      :error -> :error
    end
  end

  def cast(_), do: :error

  def load(value) when is_binary(value) do
    {:ok, value}
  end

  def dump(value) when is_binary(value) do
    {:ok, value}
  end

  def dump(_), do: :error

  def autogenerate do
    Ecto.UUID.generate()
  end
end
