defmodule Homework.UsdAndCentsConversions do
  @moduledoc """
  The Usd And cents Conversions context.
  """

  @doc """
  Converts cents to usd.

  ## Examples
  
    iex> convert_cents_to_usd(1000)
    10.0
  """
  def convert_cents_to_usd(cents) do
    cents / 100
  end

  @doc """
  Converts usd to cents

  ## Examples
  
    iex> convert_usd_to_cents(100.99)
    10099
  """
  def convert_usd_to_cents(usd) do
    trunc(usd * 100)
  end
end