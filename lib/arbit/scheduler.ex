defmodule Arbit.Scheduler do
  use GenServer
  alias Arbit.Track
  alias Arbit.Display

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  # GenServer starts and calls :work
  def init(state) do
    handle_info(:work, state)
    {:ok, state}
  end

  # Runs the job and then schedules the job
  def handle_info(:work, state) do
    # Track context
    Track.upsert_currency()
    Track.upsert_coinbase_portfolio()
    Track.upsert_bitbns_portfolio()
    # Display context
    Display.upsert_coinbasebitbns()
    schedule_work()
    {:noreply, state}
  end

  # Defines how many ms to wait
  defp schedule_work() do
    Process.send_after(self(), :work, 1800 * 1000)    # 30 mins
  end
end
