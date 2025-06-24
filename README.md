# GitHubViewer

An iOS app for browsing GitHub users and viewing their public repositories. Built with Swift, RxSwift, MVVM architecture, and tested with XCTest.

---

## 🚀 Features

- 🔍 Search GitHub users by username
- 👤 View user profiles (avatar, name, followers/following)
- 📦 Browse non-forked public repositories
- 🌐 Open repository pages in an in-app WebView
- ✅ Includes UI and unit tests

---

## 🛠 Installation

### Prerequisites

- Xcode 15+
- CocoaPods installed (`sudo gem install cocoapods`)

### Steps

1. Clone the repo:

   git clone https://github.com/yourusername/GitHubViewer.git
   cd GitHubViewer

2. Install dependencies:

   pod install
   open GitHubViewer.xcworkspace

3. (Optional) Add GitHub Token:

   - Open Info.plist
   - Add a key: GitHubToken
   - Paste your GitHub Personal Access Token as its value

---

## 📐 Architecture

The project follows a clean MVVM pattern with RxSwift:

├── Models        // API DTOs  
├── Views         // SwiftUI UI components  
├── ViewModels    // Rx-driven logic and state  
├── Services      // API service using URLSession  
├── Bridges       // ObservableObject wrappers for SwiftUI  
├── Tests         // Unit and UI tests

- ViewModels expose BehaviorRelay/PublishRelay for logic
- Bridges convert to @Published for SwiftUI compatibility
- GitHubService is abstracted via protocol for easy mocking

---

## 🧪 Testing

- Unit Tests: UserListViewModel, UserDetailViewModel via RxBlocking
- UI Tests: Navigation, search, and loading flows using XCTest

Run tests from the Test navigator in Xcode (⌘U)

---

## 📋 Requirements

- iOS 16.0+
- Swift 5.9+
- CocoaPods

