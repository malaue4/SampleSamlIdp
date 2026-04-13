import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() {
    this.popovers = []
  }

  disconnect() {
    this.popovers.forEach(p => p.dispose())
  }

  togglePopover(event) {
    const badge = event.currentTarget
    const name = badge.dataset.filterName
    const contentId = badge.dataset.bsContentId
    const template = document.getElementById(contentId)
    
    if (!template) return

    let popover = bootstrap.Popover.getInstance(badge)
    
    if (!popover) {
      popover = new bootstrap.Popover(badge, {
        content: template.innerHTML,
        sanitize: false,
        trigger: 'manual',
        placement: 'bottom',
        container: 'body'
      })
      this.popovers.push(popover)
      
      badge.addEventListener('shown.bs.popover', () => {
        const popoverEl = document.querySelector('.popover:last-child')
        if (popoverEl) {
          const input = popoverEl.querySelector('input, select, textarea')
          if (input) input.focus()
        }
      })
    }

    // Close other popovers
    this.popovers.forEach(p => {
      if (p !== popover) p.hide()
    })

    popover.toggle()
  }

  clear(event) {
    event.preventDefault()
    event.stopPropagation()
    const name = event.currentTarget.dataset.filterName
    
    // Create a temporary form to submit the clear action
    const form = document.createElement('form')
    form.method = 'GET'
    form.action = window.location.pathname
    
    // Get current params
    const urlParams = new URLSearchParams(window.location.search)
    const filterParamKey = this.element.closest('[data-filter-param-key]')?.dataset.filterParamKey || 'filter'
    
    urlParams.forEach((value, key) => {
      // Check if the key belongs to the current filter and matches the attribute to clear
      const isCurrentFilter = key.startsWith(`${filterParamKey}[`)
      const isTargetAttribute = key.includes(`[${name}]`) || key.includes(`[${name}_after]`) || key.includes(`[${name}_before]`)
      
      if (!(isCurrentFilter && isTargetAttribute)) {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = key
        input.value = value
        form.appendChild(input)
      }
    })
    
    // Reset pagination when clearing a filter
    urlParams.delete('page')
    
    document.body.appendChild(form)
    form.submit()
  }
}
