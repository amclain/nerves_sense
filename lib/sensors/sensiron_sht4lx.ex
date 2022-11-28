defmodule Sensiron.SHT4xl do
  @moduledoc """
  Sensiron SHT4xl relative humidity and temperature sensor

  See:
    https://www.mouser.com/datasheet/2/682/Sensirion_Humidity_Sensors_SHT4xI_Datasheet-2887008.pdf
  """

  @i2c_address 0x44

  # Commands
  @command_serial_number 0x89
  @soft_reset 0x94
  @command_measure_low_precision 0xE0
  @command_measure_medium_precision 0xF6
  @command_measure_high_precision 0xFD

  @doc """
  Performs a soft reset of the sensor.
  """
  @spec reset(i2c :: Circuits.I2C.bus()) :: :ok | {:error, term()}
  def reset(i2c) do
    Circuits.I2C.write(i2c, @i2c_address, <<@soft_reset>>)
  end

  @doc """
  Get the sensor's serial number as a base 16 encoded string.
  """
  @spec serial_number(i2c :: Circuits.I2C.bus()) :: {:ok, String.t()} | {:error, term}
  def serial_number(i2c) do
    with :ok <- Circuits.I2C.write(i2c, @i2c_address, <<@command_serial_number>>),
         {:ok,
          <<
            serial_byte_1::size(8),
            serial_byte_2::size(8),
            _checksum_1::size(8),
            serial_byte_3::size(8),
            serial_byte_4::size(8),
            _checksum_2::size(8)
          >>} <- Circuits.I2C.read(i2c, @i2c_address, 6) do
      {:ok, Base.encode16(<<serial_byte_1, serial_byte_2, serial_byte_3, serial_byte_4>>)}
    end
  end

  @doc """
  Take a temperature and humidity reading.

  ## Opts
  - `:units` - Units to return temperature in (`:c` - celsius, `:f` - fahrenheit). Default `:c`.
  - `:precision` - Duration and repeatability of the measurement (`:low`, `:medium`, `:high`). Default `:low`.
  """
  @spec temperature_and_humidity(i2c :: Circuits.I2C.bus(),
          units: :c | :f,
          precision: :low | :medium | :high
        ) ::
          {:ok, {temperature :: float, humidity :: float}}
          | {:error, term}
  def temperature_and_humidity(i2c, opts \\ []) do
    units = Keyword.get(opts, :units, :c)
    precision = Keyword.get(opts, :precision, :low)

    {command, wait_time} =
      case precision do
        :high -> {@command_measure_high_precision, 10}
        :medium -> {@command_measure_medium_precision, 5}
        :low -> {@command_measure_low_precision, 2}
      end

    with :ok <- Circuits.I2C.write(i2c, @i2c_address, <<command>>),
         Process.sleep(wait_time),
         {:ok,
          <<
            temperature_word::size(16),
            _checksum_1::size(8),
            humidity_word::size(16),
            _checksum_2::size(8)
          >>} <- Circuits.I2C.read(i2c, @i2c_address, 6) do
      humidity = -6 + 125 * humidity_word / 65535

      temperature =
        case units do
          :c -> -45 + 175 * temperature_word / 65535
          :f -> -49 + 315 * temperature_word / 65535
        end

      humidity =
        cond do
          humidity < 0 -> 0
          humidity > 100 -> 100
          true -> humidity
        end

      {:ok, {Float.round(temperature, 2), Float.round(humidity, 2)}}
    end
  end
end
