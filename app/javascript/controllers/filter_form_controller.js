import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    event.preventDefault()
    const form = event.currentTarget
    const formData = new FormData(form)
    
    // Get current params
    const urlParams = new URLSearchParams(window.location.search)
    
    // Merge new form data into current params
    for (const [key, value] of formData.entries()) {
      if (value) {
        urlParams.set(key, value)
      } else {
        urlParams.delete(key)
      }
    }
    
    // Reset pagination when applying a new filter
    urlParams.delete('page')
    
    // Redirect with combined params
    window.location.href = `${window.location.pathname}?${urlParams.toString()}`
  }
}
