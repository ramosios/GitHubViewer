//
//  UserDetailView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI

struct UserDetailView: View {
    @StateObject private var observable: UserDetailBridge
    @State private var selectedRepoURL: URL?

    init(username: String) {
        _observable = StateObject(wrappedValue: UserDetailBridge(username: username))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let user = observable.userDetail {
                    UserInfoCardView(user: user)
                        .accessibilityIdentifier("UserInfoCard")
                }

                if !observable.repositories.isEmpty {
                    RepositoryListView(repositories: observable.repositories) { url in
                        selectedRepoURL = url
                    }
                    .accessibilityIdentifier("RepositoryList")
                } else if !observable.isLoading {
                    Text("No public repositories found.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                        .accessibilityIdentifier("NoRepositoriesMessage")
                }

                if let error = observable.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 4)
                        .accessibilityIdentifier("DetailErrorMessage")
                }
            }
            .padding()
            .accessibilityIdentifier("UserDetailView") // Moved here
        }
        .navigationTitle("User Detail")
        .sheet(item: $selectedRepoURL) { url in
            WebViewer(url: url)
                .accessibilityIdentifier("WebViewer")
        }
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

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
