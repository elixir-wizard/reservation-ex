# Reservation

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `reservation` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:reservation, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/reservation>.

## Run
```
mix run
```

## Notes
- `read_file/0`: <br/>
Read the input.txt and return the content if ok
- `parse_records/1`: <br/>
Parse the content into reservation records list, also find the based location
- `sort_records/1`: <br/>
Sort the records by its startDateTime in ascending order.
- `group_records/1`: <br/>
Group the records per trips, assuming a new trip, if the start location is based location, or the end location and start location of adjacent records doesn't match, or the time difference is bigger than 1 day.
- `output_records/1`: <br/>
Output the records per trips, find all the locations in a trip and display them first. Consider as a trip location if you stay at a hotel or the time difference between arrival and leave is bigger than 1 day.
