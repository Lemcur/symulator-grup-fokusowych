import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["brief", "json", "radio"]
  static values = { mode: String }

  connect() {
    this.render()
  }

  switch(event) {
    this.modeValue = event.target.value
    this.render()
  }

  render() {
    const showBrief = this.modeValue === "brief"
    this.briefTarget.classList.toggle("hidden", !showBrief)
    this.jsonTarget.classList.toggle("hidden", showBrief)
  }
}
