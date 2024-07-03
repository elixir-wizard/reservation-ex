defmodule Reservation do
  @moduledoc """
  Documentation for `Reservation`.

  This module provides functionality for processing reservation records. It reads a file, parses the records, sorts them, groups them, and outputs the results. The main entry point is the `run/0` function.

  ## Usage

  ```elixir
  Reservation.run()
  defmodule Reservation do

  """

  def run() do
    read_file()
    |> parse_records()
    |> sort_records()
    |> group_records()
    |> output_records()
  end

  defp read_file() do
    case File.read("./input.txt") do
      {:ok, content} -> content
      {:error, reason} -> IO.puts("Can't read input.txt")
    end
  end

  # Parses the content of a reservation file and extracts the relevant records and base information.
  #
  # Args:
  # - content: The content of the reservation file as a string.
  #
  # Returns:
  # A tuple containing the extracted records and the base information.
  defp parse_records(content) do
    # Split the content into lines
    lines = content |> String.split("\n");

    # Find the line containing the "BASED" keyword and extract the base information
    based = lines
    |> Enum.find(fn line -> String.contains?(line, "BASED") end)
    |> String.split(": ")
    |> List.last()
    |> String.trim()

    # Filter the lines to extract the "SEGMENT" records and transform them into a structured format
    records = lines
    |> Enum.filter(fn record ->
      record |> String.split(": ") |> List.first() == "SEGMENT"
     end)
    |> Enum.map(fn record ->
      record
      |> String.trim()
      |> String.split(" ")
      |> fn
          ["SEGMENT:", "Hotel", where, startDate, "->", endDate] -> %{:mode => "Hotel", :where => where, :startDate => startDate, :endDate => endDate}
          ["SEGMENT:", "Flight", from, startDate, startTime, "->", to, endTime] -> %{:mode => "Flight", :from => from, :to => to, :startDate => startDate, :startTime => startTime, :endTime => endTime}
          ["SEGMENT:", "Train",  from, startDate, startTime, "->", to, endTime] -> %{:mode => "Train", :from => from, :to => to, :startDate => startDate, :startTime => startTime, :endTime => endTime}
        end.()
      |> fn
          all = %{:startDate => startDate, :startTime => startTime, :endTime => endTime} ->
            all
            |> Map.merge(%{
                :startDateTime => parseDateTime(startDate, startTime),
                :endDateTime => parseDateTime(startDate, endTime)
              })
          all = %{:startDate => startDate, :endDate => endDate} ->
            all
            |> Map.merge(%{
              :startDateTime => parseDateTime(startDate),
              :endDateTime => parseDateTime(endDate)
              })
        end.()
      end)

    {records, based}
  end

  # Sorts the records based on the startDateTime field.
  #
  # The function takes a tuple containing the records and a boolean value indicating the sorting order.
  # It sorts the records based on the startDateTime field in ascending order by default.
  #
  defp sort_records({records, based}) do
    records = records
    |> Enum.sort(fn a, b ->
      case a[:startDateTime] |> DateTime.compare(b[:startDateTime]) do
        :gt -> false
        :lt -> true
        _ -> true
      end
    end)
    {records, based}
  end

  # Groups records based on certain conditions.
    #
    # The function takes a tuple `({records, based})` as input and groups the records based on the following conditions:
    # - If the accumulator `acc` is empty, a new group containing the current record is created.
    # - If the current record's `:from` value matches the `based` value, it is added to the current group.
    # - If the current record's `:where` value matches the `:to` value of the last record in the current group,
    #   or if the `:where` value of the last record matches the `:from` value of the current record,
    #   or if the `:to` value of the last record matches the `:from` value of the current record,
    #   or if the `:endDateTime` value of the last record plus one day is greater than the `:startDateTime` value of the current record,
    #   then the current record is added to the current group.
    # - Otherwise, a new group containing the current record is created.
    #
    # The function returns a tuple `({records, based})` where `records` is the grouped list of records and `based` is the input value.
    defp group_records({records, based}) do
      IO.inspect(records)
      records = records
      |> Enum.reduce([], fn (record, acc) ->
        if Enum.count(acc) == 0 do
          [[record]]
        else
          last = acc |> Enum.at(-1) |> Enum.at(-1)
          cond do
            record[:from] == based -> acc ++ [[record]]

            (record[:where] != nil && record[:where] == last[:to]) ||
            (last[:where] != nil && last[:where] == record[:from]) ||
            (last[:to] != nil && last[:to] == record[:from]) ||
            ((last[:endDateTime] |> DateTime.add(1, :day)) > record[:startDateTime])
            -> acc |> List.replace_at(-1, (acc |> Enum.at(-1)) ++ [record])

            true -> acc ++ [[record]]
          end
        end
      end)
      {records, based}
    end

  # This function outputs the records of a group of trips based on certain conditions.
  # It filters the group records based on the mode of transportation and the time intervals between trips.
  # It then prints the trips and their details to the console.
  #
  # Args:
  # - group_records: A list of trip records grouped together.
  # - based: A reference value used for comparison in the filtering process.
  #
  # Returns: None
  defp output_records({group_records, based}) do
    for(group <- group_records) do
      trips = group
      |> Enum.with_index()
      |> Enum.filter(fn {record, index} ->
        cond do
          record[:mode] == "Hotel" -> true
          index > 0 && ((Enum.at(group, index - 1)[:endDateTime] |> DateTime.add(1, :day)) < record[:startDateTime]) -> true
          true -> false
        end
      end)
      |> Enum.map(fn {record, index} ->
        case record[:mode] do
          "Hotel" -> record[:where]
          _ -> record[:from]
        end
       end)

      last_to = List.last(group)[:to]
      trips = trips ++ case last_to do
        nil -> []
        ^based -> []
        _ -> [last_to]
      end

      IO.puts("TRIP to #{trips |> Enum.join(", ")}")

      for(record <- group) do
        cond do
          record[:mode] == "Hotel" ->
            IO.puts("#{record[:mode]} at #{record[:where]} on #{record[:startDate]} to #{record[:endDate]}")
          true -> IO.puts("#{record[:mode]} from #{record[:from]} to #{record[:to]} at #{record[:startDate]} #{record[:startTime]} to #{record[:endTime]}")
        end
      end
      IO.puts("")
    end
  end

  # Parses the given date and time strings and returns a DateTime object.

  # ## Examples

  #   iex> parseDateTime("2022-01-01", "12:00")
  #   ~U[2022-01-01T12:00:00Z]
  defp parseDateTime(date, time) do
    {:ok, datetime, _} = DateTime.from_iso8601("#{date}T#{time}:00Z")
    datetime
    end


  # Parses the given date string into a DateTime object.
  #
  # Examples
  #
  # iex> parseDateTime("2022-01-01")
  # ~U[2022-01-01T23:59:59Z]
  #
  # iex> parseDateTime("2022-12-31")
  # ~U[2022-12-31T23:59:59Z]
  #
  # Returns a DateTime object.
  defp parseDateTime(date) do
      {:ok, datetime, _} = DateTime.from_iso8601("#{date}T23:59:59Z")
      datetime
    end

end
