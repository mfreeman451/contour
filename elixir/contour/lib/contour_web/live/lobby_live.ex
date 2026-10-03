defmodule ContourWeb.LobbyLive do
  use ContourWeb, :live_view

  @impl true
  def mount(_params, _session, socket), do: {:ok, assign(socket, :page_title, "Command station")}

  @impl true
  def render(assigns) do
    ~H"""
    <main class="mx-auto max-w-4xl px-6 py-16">
      <p class="text-xs tracking-[0.3em] text-lime-300">CONTOUR / MASKIROVKA</p>
      <h1 class="mt-6 text-4xl font-semibold">Command station</h1>
      <p class="mt-4 text-stone-400">Welcome, {@current_scope.user.display_name}.</p>
      <div class="mt-10 border-y border-stone-800 py-8">
        <h2 class="text-xl">The battlefield is taking shape.</h2>
        <p class="mt-3 text-stone-400">
          Match rooms and tactical play will arrive in the next alpha milestones.
        </p>
      </div>
      <.form for={%{}} action={~p"/auth/logout"} class="mt-8">
        <button class="rounded border border-stone-700 px-4 py-2 text-sm hover:border-stone-400">Sign out</button>
      </.form>
    </main>
    """
  end
end
