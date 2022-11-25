defmodule FixFiles do
  @moduledoc """
  Documentation for `FixFiles`.
  """

  # unsupported charachters:  \  /  "   :  < >  |  *  ?

  @doc """
  Hello world.

  ## Examples

      iex> FixFiles.hello()
      :world

  """
  require Logger
  require Path



  def list_all(filepath) do

    filename = "data.log"
    logfile = archive_file(filename)

    _list_all(filepath, logfile)
    File.close(logfile)
  end

  defp _list_all(filepath, logfile) do
    log("starting: " <> filepath, logfile)
    file = Path.basename(filepath)

    cond do

      String.contains?(file, ".DS_Store") ->

        log("removing .DS_Store", logfile)
        result = File.rm_rf(filepath)
        case result do
          {:ok, [^filepath]} ->
            log("removed .DS_Store", logfile)

          _ ->
            log("failed to remove .DS_Store", logfile)
            Logger.info("i am here")
            Logger.info(result)

        end
        []

      String.contains?(filepath, "/.") ->
          []
      true ->
        new_file = file
        |> String.trim
        |> String.replace("\\", "-")
        |> String.replace("\/", "-")
        |> String.replace("\"", "-")
        |> String.replace(":", "-")
        |> String.replace("<", "-")
        |> String.replace(">", "-")
        |> String.replace("|", "-")
        |> String.replace("*", "-")
        |> String.replace("?", "-")

        cond do
          file != new_file ->
            new_filepath = rename_file(filepath, new_file, logfile)
            expand(File.ls(new_filepath), new_filepath, logfile)
          true ->
            expand(File.ls(filepath), filepath, logfile)
        end
    end
  end

  defp rename_file(filepath, new_file, logfile) do
    new_filepath = Path.join(Path.dirname(filepath), new_file)
    result = File.rename(filepath, new_filepath)
    case result do
      :ok ->
        log("rename " <> filepath <> " to " <> new_filepath, logfile)
        new_filepath
      {:error, :eexist} ->
        log("rename failed, file already existed", logfile)
        new_filepath = new_filepath <> "-DUP-" <> string_of_length(4)
        log("trying new filepath: " <> new_filepath, logfile)
        File.rename!(filepath, new_filepath)
        new_filepath
      {:error, reason} ->
          log("rename failed, " <> Atom.to_string(reason), logfile)
      _ ->
        log("rename failed, unknown reason", logfile)
        Logger.info(result)

    end

  end

  defp archive_file(filename) do
    {:ok, logfile} = File.open(filename, [:append])
    cond do
      File.exists?(filename) ->
        rename_file(filename, create_archive_filename(filename), logfile)
        logfile
      true ->
        {:ok, :no_file}
    end
  end

  defp create_archive_filename(filename) do
    [ date | [ time | _ ]] = :calendar.local_time()
      |> Tuple.to_list
      |> Enum.map(fn x -> Tuple.to_list(x) end)

    filename <> "_" <> Enum.join(date, "-") <>
      "_" <> Enum.join(time, "-")
  end

  defp expand({:ok, files}, path, logfile) do
    files
    |> Enum.flat_map(&_list_all("#{path}/#{&1}", logfile))
    |> Enum.map(&log(&1, logfile))
  end



  defp expand({:error, _}, path, _) do
    [path]
  end

  defp log(entry,logfile,mode \\ :info)

  defp log(:ok, _, _) do
    :ok
  end

  defp log(entry, logfile, mode) do

    try do
      message = create_archive_filename("") <> " " <> entry <> "\n"
      cond do
        mode == :error ->
          message = "error: " <> message
          Logger.error(message)
          IO.binwrite(logfile, message)

        true ->
          message = "info: " <> message
          Logger.info(message)
          IO.binwrite(logfile, message)
      end
    rescue

      e in File.Error ->
        Logger.error(Exception.message(e))
    end
  end


  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789" |> String.split("")

  def string_of_length(length) do
    Enum.reduce((1..length), [], fn (_i, acc) ->
      [Enum.random(@chars) | acc]
    end) |> Enum.join("")
  end


end
