import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]

  add(event) {
    event.preventDefault()
    const clone = this.templateTarget.content.cloneNode(true)
    const index = this.listTarget.children.length
    // Update the title number
    const title = clone.querySelector("[data-cert-index]")
    if (title) title.textContent = title.textContent.replace("%{count}", index + 1)
    this.listTarget.appendChild(clone)
  }

  remove(event) {
    event.preventDefault()
    event.target.closest("[data-cert-entry]").remove()
  }
}