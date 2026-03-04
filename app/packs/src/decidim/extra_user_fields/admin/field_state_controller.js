import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["enabled", "required", "state", "subfields", "row"]
  static values = {
    enabledState: { type: String, default: "optional" },
    disabledState: { type: String, default: "disabled" }
  }

  connect() {
    this.sync()
  }

  toggleEnabled() {
    if (!this.enabledTarget.checked) {
      if (this.hasRequiredTarget) {
        this.requiredTarget.checked = false
        this.requiredTarget.disabled = true
      }
      this.stateTarget.value = this.disabledStateValue
    } else {
      if (this.hasRequiredTarget) {
        this.requiredTarget.disabled = false
      }
      this.stateTarget.value = this.enabledStateValue
    }

    this.updateRow()
    this.updateSubfields()
  }

  toggleRequired() {
    if (this.requiredTarget.checked) {
      this.stateTarget.value = "required"
    } else {
      this.stateTarget.value = this.enabledStateValue
    }

    this.updateRow()
  }

  sync() {
    const state = this.stateTarget.value
    const enabled = state !== this.disabledStateValue && state !== ""

    this.enabledTarget.checked = enabled

    if (this.hasRequiredTarget) {
      this.requiredTarget.checked = state === "required"
      this.requiredTarget.disabled = !enabled
    }

    this.updateRow()
    this.updateSubfields()
  }

  updateRow() {
    if (!this.hasRowTarget) return

    const row = this.rowTarget
    row.classList.remove("field-row--disabled", "field-row--required")

    const state = this.stateTarget.value
    if (state === this.disabledStateValue || state === "") {
      row.classList.add("field-row--disabled")
    } else if (state === "required") {
      row.classList.add("field-row--required")
    }
  }

  updateSubfields() {
    const enabled = this.enabledTarget.checked
    this.subfieldsTargets.forEach((el) => {
      el.hidden = !enabled
    })
  }
}
