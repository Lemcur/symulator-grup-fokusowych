import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    status: String,
    focusGroupId: String
  }

  static TRIGGER_STATES = ["collecting_opinions", "completed"]

  connect() {
    if (!this.hasStatusValue || !this.hasFocusGroupIdValue) return

    const key = `fg:${this.focusGroupIdValue}:last_status`
    const prev = localStorage.getItem(key)
    const curr = this.statusValue

    if (prev !== curr && this.constructor.TRIGGER_STATES.includes(curr)) {
      this.clearPersonaState()
    }

    localStorage.setItem(key, curr)
  }

  clearPersonaState() {
    const toRemove = []
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i)
      if (k && k.startsWith("pd:persona-")) toRemove.push(k)
    }
    toRemove.forEach(k => localStorage.removeItem(k))
  }
}
