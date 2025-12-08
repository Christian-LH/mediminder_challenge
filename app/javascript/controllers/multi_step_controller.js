import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["genderStep", "dateStep", "nameStep"]

  nextStep() {
    const selected = this.genderStepTarget.querySelector('input[name="profile[gender]"]:checked')
    if (selected) {
      this.genderStepTarget.classList.add("d-none")
      this.dateStepTarget.classList.remove("d-none")
    } else {
      alert("Please choose a gender first.")
    }
  }

  nextStep2() {
    // get year / month / date
    const year = this.dateStepTarget.querySelector('[name="profile[birthday(1i)]"]').value
    const month = this.dateStepTarget.querySelector('[name="profile[birthday(2i)]"]').value
    const day = this.dateStepTarget.querySelector('[name="profile[birthday(3i)]"]').value

    // check
    if (!year || !month || !day) {
      alert("Please enter a complete date of birth.")
      return
    }

    // generate date | month-1 because JS counts months 0–11
    const date = new Date(year, month - 1, day)

    // validation
    const valid =
      date.getFullYear() == year &&
      date.getMonth() == month - 1 &&
      date.getDate() == day

    if (!valid) {
      alert("Please enter a valid date of birth.")
      return
    }

    this.dateStepTarget.classList.add("d-none")
    this.nameStepTarget.classList.remove("d-none")
  }

}
