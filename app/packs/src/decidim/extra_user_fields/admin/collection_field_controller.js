import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setupEventListeners()
  }

  setupEventListeners() {
    const form = this.element
    
    // Handle enabled checkboxes - disable required when unchecking enabled
    form.querySelectorAll(".collection-field-enabled").forEach((checkbox) => {
      checkbox.addEventListener("change", (e) => this.toggleRequired(e))
    })
  }

  toggleRequired(event) {
    const enabledCheckbox = event.target
    const field = enabledCheckbox.dataset.field
    
    const row = enabledCheckbox.closest("tr")
    const requiredCheckbox = row?.querySelector(
      `.collection-field-required[data-field="${field}"]`
    )

    if (!requiredCheckbox) return

    if (!enabledCheckbox.checked) {
      // Disable required when enabled is unchecked
      requiredCheckbox.checked = false
      requiredCheckbox.disabled = true
    } else {
      // Enable required when enabled is checked
      requiredCheckbox.disabled = false
    }
  }
}
