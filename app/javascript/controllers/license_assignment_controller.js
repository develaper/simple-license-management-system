import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subscription", "user", "submitButton", "unassignButton", "form", "unassignForm"]

  connect() {
    this.selectedSubscriptionId = null
    this.selectedProductId = null
    this.selectedUserIds = new Set()
    this.selectedSubscriptions = new Set()
    this.updateButtons()
  }

  selectSubscription(event) {
    const element = event.currentTarget
    const subscriptionId = element.dataset.subscriptionId
    const productId = element.dataset.productId

    if (this.selectedSubscriptions && this.selectedSubscriptions.has(subscriptionId)) {
      this.selectedSubscriptions.delete(subscriptionId)
      element.classList.remove("border-indigo-500", "ring-2", "ring-indigo-200")
    } else {
      if (!this.selectedSubscriptions) {
        this.selectedSubscriptions = new Set()
      }
      this.selectedSubscriptions.add(subscriptionId)
      element.classList.add("border-indigo-500", "ring-2", "ring-indigo-200")
    }

    this.selectedSubscriptionId = subscriptionId
    this.selectedProductId = productId
    this.updateButtons()
  }

  selectUser(event) {
    const element = event.currentTarget
    const userId = element.dataset.userId

    if (this.selectedUserIds.has(userId)) {
      this.selectedUserIds.delete(userId)
      element.classList.remove("border-indigo-500", "ring-2", "ring-indigo-200")
    } else {
      this.selectedUserIds.add(userId)
      element.classList.add("border-indigo-500", "ring-2", "ring-indigo-200")
    }

    this.updateButtons()
  }

  updateButtons() {
    const canSubmit = this.selectedSubscriptionId && this.selectedUserIds.size > 0
    this.submitButtonTarget.disabled = !canSubmit
    this.unassignButtonTarget.disabled = !(this.selectedProductId && this.selectedUserIds.size > 0)
  }

  submit(event) {
    event.preventDefault()
    const form = this.formTarget

    form.querySelectorAll('input[name="license_assignment[user_ids][]"]').forEach(el => el.remove())
    form.querySelectorAll('input[name="license_assignment[subscription_ids][]"]').forEach(el => el.remove())

    this.selectedUserIds.forEach(userId => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'license_assignment[user_ids][]'
      input.value = userId
      form.appendChild(input)
    })

    this.selectedSubscriptions.forEach(subscriptionId => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'license_assignment[subscription_ids][]'
      input.value = subscriptionId
      form.appendChild(input)
    })

    form.submit()
  }

  submitUnassign(event) {
    event.preventDefault()
    const form = this.unassignFormTarget

    form.querySelectorAll('input[name="license_assignment[user_ids][]"]').forEach(el => el.remove())
    form.querySelector('input[name="license_assignment[product_id]"]')?.remove()

    this.selectedUserIds.forEach(userId => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'license_assignment[user_ids][]'
      input.value = userId
      form.appendChild(input)
    })

    const productInput = document.createElement('input')
    productInput.type = 'hidden'
    productInput.name = 'license_assignment[product_id]'
    productInput.value = this.selectedProductId
    form.appendChild(productInput)

    form.submit()
  }
}