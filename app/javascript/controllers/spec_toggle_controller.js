import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["brief", "structured", "json", "radio"]
  static values = { mode: String }

  connect() {
    this.render()
  }

  switch(event) {
    this.modeValue = event.target.value
    this.render()
  }

  render() {
    const mode = this.modeValue
    if (this.hasBriefTarget) this.briefTarget.classList.toggle("hidden", mode !== "brief")
    if (this.hasStructuredTarget) this.structuredTarget.classList.toggle("hidden", mode !== "structured")
    if (this.hasJsonTarget) this.jsonTarget.classList.toggle("hidden", mode !== "json")
  }
}
