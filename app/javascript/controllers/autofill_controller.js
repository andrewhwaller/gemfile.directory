import { Controller } from "@hotwired/stimulus"

// Parse GitHub URL and extract repo info, returns null if invalid
const parseGitHubUrl = (url) => {
  if (!url || typeof url !== "string") return null
  
  try {
    const urlObj = new URL(url)
    if (urlObj.hostname !== "github.com") return null
    
    const parts = urlObj.pathname.replace(/^\/?|\/?$/g, '').split('/')
    return (parts.length >= 2) ? { owner: parts[0], repo: parts[1] } : null
  } catch {
    return null
  }
}

export default class extends Controller {
  static targets = ["gemfileField", "message", "nameField", "appLinkField", "notesField"]

  autofill(event) {
    const inputValue = event.target.value.trim()
    this.clearMessage()
    if (!inputValue) return
    this.processGithubUrl(inputValue)
  }
  
  async processGithubUrl(url) {
    this.repoData = null
    
    const repoInfo = parseGitHubUrl(url)
    if (!repoInfo) {
      if (url.includes('http') || url.includes('github')) {
        this.showMessage("Please enter a valid GitHub repository URL", "error")
      }
      return
    }
    
    this.showMessage("Fetching repository information...", "info")
    
    try {
      await this.fetchRepoData(repoInfo.owner, repoInfo.repo)
      await this.fetchGemfile()
      this.fillMetadataFields()
    } catch (error) {
      console.error("Error:", error)
      this.showMessage(error.message || "Failed to fetch repository information", "error")
    }
  }
  
  fillMetadataFields() {
    if (!this.repoData || !this.hasNameFieldTarget) return
    
    // Fill fields only if they're empty
    if (this.nameFieldTarget.value === "") {
      this.nameFieldTarget.value = this.repoData.name
        .replace(/[-_]/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase())
    }
    
    if (this.hasAppLinkFieldTarget && this.appLinkFieldTarget.value === "" && this.repoData.homepage) {
      this.appLinkFieldTarget.value = this.repoData.homepage
    }
    
    if (this.hasNotesFieldTarget && this.notesFieldTarget.value === "" && this.repoData.description) {
      this.notesFieldTarget.value = this.repoData.description
    }
  }
  
  async fetchRepoData(owner, repo) {
    const response = await fetch(`https://api.github.com/repos/${owner}/${repo}`)
    if (!response.ok) throw new Error("Repository not found or not accessible")
    
    this.repoData = await response.json()
    this.showMessage("Found repository! Fetching Gemfile...", "info")
    return this.repoData
  }
  
  async fetchGemfile() {
    if (!this.repoData) return
    
    const { default_branch, owner, name, full_name } = this.repoData
    const gemfileUrl = `https://raw.githubusercontent.com/${owner.login}/${name}/${default_branch}/Gemfile`
    
    this.showMessage(`Fetching Gemfile from ${default_branch} branch...`, "info")
    
    const response = await fetch(gemfileUrl)
    if (!response.ok) throw new Error(`Could not find a Gemfile in this repository`)
    
    const gemfileContent = await response.text()
    if (!gemfileContent.trim()) throw new Error("Gemfile exists but is empty")
    
    this.gemfileFieldTarget.value = gemfileContent
    this.showMessage(`Gemfile successfully fetched from ${full_name}`, "success")
    return gemfileContent
  }
  
  showMessage(text, type = "info") {
    this.messageTarget.textContent = text
    this.messageTarget.setAttribute("data-status", type)
  }
  
  clearMessage() {
    this.messageTarget.textContent = ""
    this.messageTarget.removeAttribute("data-status")
  }
}
