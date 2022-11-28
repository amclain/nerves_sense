defmodule Circuits.I2C do
  @moduledoc false

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:next_response]
  end

  def open("i2c-test") do
    GenServer.start_link(__MODULE__, nil)
  end

  # Serial number
  def write(pid, 0x44, <<0x89>>), do: next_response(pid, <<16, 150, 112, 108, 49, 148>>)
  # Reset
  def write(pid, 0x44, <<0x94>>), do: next_response(pid, <<>>)
  # Measure low precision
  def write(pid, 0x44, <<0xE0>>), do: next_response(pid, <<109, 68, 109, 51, 175, 204>>)
  # Measure medium precision
  def write(pid, 0x44, <<0xF6>>), do: next_response(pid, <<109, 70, 15, 51, 186, 122>>)
  # Measure high precision
  def write(pid, 0x44, <<0xFD>>), do: next_response(pid, <<109, 62, 78, 52, 26, 40>>)

  def read(pid, 0x44, _length) do
    GenServer.call(pid, :read)
  end

  @impl GenServer
  def init(_) do
    {:ok, %State{next_response: nil}}
  end

  @impl GenServer
  def handle_call({:next_response, data}, _from, state) do
    {:reply, :ok, %State{state | next_response: data}}
  end

  @impl GenServer
  def handle_call(:read, _from, state) do
    response =
      case state.next_response do
        nil -> {:error, :i2c_nak}
        data -> {:ok, data}
      end

    {:reply, response, %State{state | next_response: nil}}
  end

  defp next_response(pid, data) do
    GenServer.call(pid, {:next_response, data})
  end
end
