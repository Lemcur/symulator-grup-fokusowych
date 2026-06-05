import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { key: String }

  connect() {
    if (!this.hasKeyValue) return
    if (localStorage.getItem(this.storageKey()) === "1") {
      this.element.setAttribute("open", "")
    }
  }

  save() {
    if (!this.hasKeyValue) return
    if (this.element.open) {
      localStorage.setItem(this.storageKey(), "1")
    } else {
      localStorage.removeItem(this.storageKey())
    }
  }

  storageKey() {
    return `pd:${this.keyValue}`
  }
}
