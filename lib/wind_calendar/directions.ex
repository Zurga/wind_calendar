defmodule WindCalendar.Directions do
  @wind_direction_icon %{
    # North
    0 => %{"into" => "↑", "follow" => "↓", "abbreviation" => "N"},
    # North-Northeast
    1 => %{"into" => "↑↗", "follow" => "↓↙", "abbreviation" => "NNE"},
    # Northeast
    2 => %{"into" => "↗", "follow" => "↙", "abbreviation" => "NE"},
    # East-Northeast
    3 => %{"into" => "→↗", "follow" => "←↙", "abbreviation" => "ENE"},
    # East
    4 => %{"into" => "→", "follow" => "←", "abbreviation" => "E"},
    # East-Southeast
    5 => %{"into" => "→↘", "follow" => "←↖", "abbreviation" => "ESE"},
    # Southeast
    6 => %{"into" => "↘", "follow" => "↖", "abbreviation" => "SE"},
    # South-Southeast
    7 => %{"into" => "↓↘", "follow" => "↑↖", "abbreviation" => "SSE"},
    # South
    8 => %{"into" => "↓", "follow" => "↑", "abbreviation" => "S"},
    # South-Southwest
    9 => %{"into" => "↓↙", "follow" => "↑↗", "abbreviation" => "SSW"},
    # Southwest
    10 => %{"into" => "↙", "follow" => "↗", "abbreviation" => "SW"},
    # West-Southwest
    11 => %{"into" => "←↙", "follow" => "→↗", "abbreviation" => "WSW"},
    # West
    12 => %{"into" => "←", "follow" => "→", "abbreviation" => "W"},
    # West-Northwest
    13 => %{"into" => "←↖", "follow" => "→↘", "abbreviation" => "WNW"},
    # Northwest
    14 => %{"into" => "↖", "follow" => "↘", "abbreviation" => "NW"},
    # North-Northwest
    15 => %{"into" => "↑↖", "follow" => "↓↘", "abbreviation" => "NNW"}
  }

  def directions, do: @wind_direction_icon

  def as_string(direction, format) do
    @wind_direction_icon[direction][format]
  end
end
