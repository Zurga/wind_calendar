defmodule WindCalendarWeb.Components.Table do
  @moduledoc """
  A simple HTML table.

  You can create a table by setting a souce `data` to it and defining
  columns using the `Table.Column` component.
  """

  use WindCalendarWeb.Component

  @doc "The id of the table"
  prop id, :string

  @doc "The data that populates the table"
  prop data, :generator, required: true

  @doc "Whether or not the data prop comes from a stream or not"
  prop stream, :boolean

  prop on_scroll, :fun

  @doc "The CSS class for the wrapping `<div>` element"
  prop class, :css_class

  @doc "The columns of the table"
  prop columns, :list

  @doc "The component that renders a row"
  slot default, generator_prop: :data, required: true

  def render(assigns) do
    assigns = assigns
    |> Context.put(WindCalendarWeb, presentation: :table)
    |> Context.put(__MODULE__, columns: assigns.columns)

    ~F"""
    <div {=@id} class={@class}>
      <table>
        <thead>
          <tr>
            <th :for={{_, label} <- @columns}>
              {label}
            </th>
          </tr>
        </thead>
        <tbody id={"#{@id}_container"} phx-update={(@stream && "stream") || ""}>
          {#if @stream}
            {#for item <- @data}
              <#slot {@default} generator_value={item} />
            {/for}
          {#else}
            <tr
              :for={item <- @data}
            >
              <td :for={col <- @cols}>
                <span><#slot {col} generator_value={item} /></span>
              </td>
            </tr>
          {/if}
        </tbody>
      </table>
    </div>
  """
  end
end
