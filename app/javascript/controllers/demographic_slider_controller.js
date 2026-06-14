import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slider", "value", "sum"]

  connect() {
    this.recompute()
  }

  update() {
    this.recompute()
  }

  recompute() {
    const weights = this.sliderTargets.map(el => Math.max(0, Number(el.value) || 0))
    const total = weights.reduce((a, b) => a + b, 0)

    if (this.hasSumTarget) {
      this.sumTarget.textContent = `Suma wag: ${total}`
      this.sumTarget.classList.toggle("text-gray-400", total === 0)
      this.sumTarget.classList.toggle("text-indigo-600", total > 0)
    }

    this.sliderTargets.forEach((el, idx) => {
      if (!this.valueTargets[idx]) return
      const value = weights[idx]
      const pct = total > 0 ? Math.round((value / total) * 100) : 0
      this.valueTargets[idx].textContent = `${pct}%`
      this.valueTargets[idx].classList.toggle("text-gray-400", pct === 0)
      this.valueTargets[idx].classList.toggle("text-indigo-600", pct > 0)
    })
  }
}
