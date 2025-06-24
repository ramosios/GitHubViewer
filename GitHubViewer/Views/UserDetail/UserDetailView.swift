//
//  UserDetailView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  Displays a user's profile information along with their public repositories.
//  Supports loading state, error handling, and repository link presentation.
//

import SwiftUI

struct UserDetailView: View {
    @StateObject private var observable: UserDetailBridge
    @State private var selectedRepoURL: URL?

    /// Initializes the view and starts loading data for the given username.
    /// - Parameter username: The GitHub username to display details for.
    init(username: String) {
        _observable = StateObject(wrappedValue: UserDetailBridge(username: username))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // User profile section
                if let user = observable.userDetail {
                    UserInfoCardView(user: user)
                        .accessibilityIdentifier("UserInfoCard")
                }

                // Repository list section
                if !observable.repositories.isEmpty {
                    RepositoryListView(repositories: observable.repositories) { url in
                        selectedRepoURL = url
                    }
                    .accessibilityIdentifier("RepositoryList")
                } else if !observable.isLoading {
                    // Message shown when no repos exist and not loading
                    Text("No public repositories found.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                        .accessibilityIdentifier("NoRepositoriesMessage")
                }

                // Error message if one exists
                if let error = observable.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 4)
                        .accessibilityIdentifier("DetailErrorMessage")
                }
            }
            .padding()
            .accessibilityIdentifier("UserDetailView")
        }
        .navigationTitle("User Detail")

        // Repository link presentation as a modal sheet
        .sheet(item: $selectedRepoURL) { url in
            WebViewer(url: url)
                .accessibilityIdentifier("WebViewer")
        }

        // Fullscreen loading overlay
        .overlay {
            if observable.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
                    .zIndex(1)
                    .accessibilityIdentifier("DetailLoadingIndicator")
            }
        }
    }
}

// Allows URL to be used as a sheet item
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
