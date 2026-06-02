import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    intervalMs: { type: Number, default: 3000 }
  }

  connect() {
    if (!this.hasUrlValue) return
    this.timer = setInterval(() => this.tick(), this.intervalMsValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    if (this.element.tagName !== "TURBO-FRAME") return
    const sep = this.urlValue.includes("?") ? "&" : "?"
    this.element.src = `${this.urlValue}${sep}_t=${Date.now()}`
  }
}
