import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["genderStep", "dateStep"]

  nextStep() {
    const selected = this.genderStepTarget.querySelector('input[name="profile[gender]"]:checked')
    if (selected) {
      this.genderStepTarget.classList.add("d-none")
      this.dateStepTarget.classList.remove("d-none")
    } else {
      alert("Bitte wähle zuerst ein Geschlecht aus.")
    }
  }
}
