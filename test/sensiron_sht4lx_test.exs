defmodule Sensiron.SHT4xl.Test do
  use ExUnit.Case

  test "reset sensor" do
    {:ok, i2c} = Circuits.I2C.open("i2c-test")
    assert Sensiron.SHT4xl.reset(i2c) == :ok
  end

  test "get serial number" do
    {:ok, i2c} = Circuits.I2C.open("i2c-test")
    assert Sensiron.SHT4xl.serial_number(i2c) == {:ok, "10966C31"}
  end

  test "get temperature and humidity" do
    {:ok, i2c} = Circuits.I2C.open("i2c-test")

    assert Sensiron.SHT4xl.temperature_and_humidity(i2c) ==
             {:ok, {29.69, 19.24}}

    assert Sensiron.SHT4xl.temperature_and_humidity(i2c, units: :f) ==
             {:ok, {85.45, 19.24}}

    assert Sensiron.SHT4xl.temperature_and_humidity(i2c, precision: :medium) ==
             {:ok, {29.7, 19.26}}

    assert Sensiron.SHT4xl.temperature_and_humidity(i2c, precision: :high) ==
             {:ok, {29.68, 19.44}}
  end
end
