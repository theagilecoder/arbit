defmodule ArbitWeb.PageController do
  use ArbitWeb, :controller
  alias Arbit.Track

  # Landing Page
  def index(conn, _params) do
    render(conn, "index.html")
  end

  # FAQ page
  def show(conn, _params) do
    conversion = Track.get_conversion_amount("USD-INR")
    render(conn, "show.html", conversion: conversion)
  end
end
