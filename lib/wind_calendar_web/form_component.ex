defmodule WindCalendarWeb.FormComponent do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Punkix.FormComponent
      alias Surface.Components.Form
      alias Surface.Components.Form.{ErrorTag, Field, Label}
      import unquote(__MODULE__)

      unquote(WindCalendarWeb.html_helpers())

      data changeset, :changeset
    end
  end
#   def autosave(%{assigns: %{action: :new}} = socket, params) do
#     changeset = do_change(params, socket)

#     assign(socket, changeset: changeset, saved: false)
#   end

#   def autosave(%{assigns: %{action: action}} = socket, params) do
#     changeset = do_change(params, socket)

#     socket
#     |> assign(changeset: changeset)
#     |> save(socket.assigns.action, params)
#     |> maybe_put_changeset(socket)
#   end

#   defp maybe_put_changeset(result, socket) do
#     case result do
#       {:ok, socket} ->
#         assign(socket, saved: true)

#       {:error, changeset} ->
#         assign(socket, changeset: changeset, saved: false)
#     end
#   end

#   defp do_change(params, socket) do
#     change(params, socket)
#     |> Map.put(:action, :validate)
#   end

#   @impl true
#   def handle_event("unsaved", _, socket),
#     do: {:noreply, assign(socket, saved: false)}
end
