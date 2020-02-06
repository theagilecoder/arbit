defmodule ArbitWeb.ResultView do
  use ArbitWeb, :view

  alias Arbit.Track.Result

  def usatoindia(results) do
    results
    |> Enum.filter(fn x -> x.difference > 0 end)
    |> Enum.sort_by(fn p -> p.difference end, &>=/2)
  end

  def indiatousa(results) do
    results
    |> Enum.filter(fn x -> x.difference < 0 end)
    |> Enum.sort_by(fn p -> p.difference end, &<=/2)
  end
end
