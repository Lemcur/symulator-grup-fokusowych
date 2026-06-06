import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter", "remaining", "warning", "previews"]
  static values = {
    attached: Number,
    max: Number,
    maxBytes: Number
  }

  connect() {
    this.selected = []
    this.update()
  }

  inputChanged() {
    const incoming = this.inputTarget.files ? Array.from(this.inputTarget.files) : []
    incoming.forEach(file => {
      const duplicate = this.selected.some(f => f.name === file.name && f.size === file.size)
      if (!duplicate) this.selected.push(file)
    })
    this.syncInputFiles()
    this.update()
  }

  removeSelected(event) {
    const idx = Number(event.currentTarget.dataset.index)
    if (Number.isNaN(idx)) return
    this.selected.splice(idx, 1)
    this.syncInputFiles()
    this.update()
  }

  syncInputFiles() {
    const dt = new DataTransfer()
    this.selected.forEach(file => dt.items.add(file))
    this.inputTarget.files = dt.files
  }

  update() {
    const selectedCount = this.selected.length
    const total = this.attachedValue + selectedCount
    const remaining = Math.max(this.maxValue - total, 0)
    const overLimit = total > this.maxValue
    const oversized = this.selected.find(f => f.size > this.maxBytesValue)

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${total}/${this.maxValue} zdjęć`
      this.counterTarget.classList.toggle("text-red-600", overLimit)
      this.counterTarget.classList.toggle("font-semibold", overLimit)
    }

    if (this.hasRemainingTarget) {
      if (overLimit) {
        this.remainingTarget.textContent = `Wybrano ${selectedCount} plików - to za dużo o ${total - this.maxValue}.`
      } else {
        this.remainingTarget.textContent = `Możesz dodać jeszcze ${remaining}.`
      }
    }

    if (this.hasWarningTarget) {
      const messages = []
      if (overLimit) messages.push(`Przekroczono limit ${this.maxValue} zdjęć.`)
      if (oversized) {
        const mb = (this.maxBytesValue / (1024 * 1024)).toFixed(0)
        messages.push(`Plik "${oversized.name}" przekracza ${mb} MB.`)
      }
      this.warningTarget.textContent = messages.join(" ")
      this.warningTarget.classList.toggle("hidden", messages.length === 0)
    }

    this.renderPreviews()
  }

  renderPreviews() {
    if (!this.hasPreviewsTarget) return
    this.previewsTarget.innerHTML = ""

    this.selected.forEach((file, index) => {
      const tile = document.createElement("div")
      tile.className = "relative border border-indigo-200 rounded overflow-hidden bg-indigo-50"

      const img = document.createElement("img")
      img.src = URL.createObjectURL(file)
      img.className = "w-full h-32 object-cover"
      img.onload = () => URL.revokeObjectURL(img.src)
      tile.appendChild(img)

      const label = document.createElement("div")
      label.className = "px-2 py-1 text-xs text-indigo-900 truncate"
      label.textContent = file.name
      tile.appendChild(label)

      const btn = document.createElement("button")
      btn.type = "button"
      btn.dataset.index = index
      btn.dataset.action = "image-picker#removeSelected"
      btn.className = "absolute top-1 right-1 px-2 py-1 text-xs bg-red-600 text-white rounded hover:bg-red-700"
      btn.textContent = "Usuń"
      tile.appendChild(btn)

      this.previewsTarget.appendChild(tile)
    })
  }
}
