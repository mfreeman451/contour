import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

const csrfToken = document.querySelector<HTMLMetaElement>("meta[name='csrf-token']")?.content
if (!csrfToken) throw new Error("Missing CSRF token")

const liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })
liveSocket.connect()
