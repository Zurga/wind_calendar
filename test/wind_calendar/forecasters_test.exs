defmodule WeatherCalendar.ForecastersTest do
  alias WeatherCalendar.Forecasters
  use ExUnit.Case

  describe "model selection based on lat lon" do
    test "knmi_seamless" do
      assert Forecasters.get_model(52.0, 4.9) == "knmi_seamless"
    end
  end
end
