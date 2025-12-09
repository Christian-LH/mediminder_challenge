import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progressBar", "genderStep", "dateStep", "nameStep"]


  // saves steps order
  connect() {
    this.steps = [this.genderStepTarget, this.dateStepTarget, this.nameStepTarget]
    this.currentStep = 0
    this.updateProgress()
  }

  // Step 1 Gender
  nextStep() {
    const selected = this.genderStepTarget.querySelector('input[name="profile[gender]"]:checked')
    if (!selected) {
      alert("Please choose a gender first.")
      return
    }
    this._goToStep(1)
  }

  // Step 2 Birthday
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

    this._goToStep(2)
  }

   // change steps
  _goToStep(stepIndex) {
    if (stepIndex < 0 || stepIndex >= this.steps.length) return

    this.steps[this.currentStep].classList.add("d-none")
    this.steps[stepIndex].classList.remove("d-none")
    this.currentStep = stepIndex
    this.updateProgress()
  }

  // Update Progressbar
  updateProgress() {
    if (!this.hasProgressBarTarget) return

    const progressPercent = ((this.currentStep + 1) / this.steps.length) * 100
    this.progressBarTarget.style.width = `${progressPercent}%`
    this.progressBarTarget.setAttribute("aria-valuenow", progressPercent)
  }
}
