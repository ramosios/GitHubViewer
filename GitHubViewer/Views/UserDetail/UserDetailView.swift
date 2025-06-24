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
                }

                if !observable.repositories.isEmpty {
                    RepositoryListView(repositories: observable.repositories) { url in
                        selectedRepoURL = url
                    }
                } else if !observable.isLoading {
                    Text("No public repositories found.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                }

                if let error = observable.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .navigationTitle("User Detail")
        .sheet(item: $selectedRepoURL) { url in
            WebViewer(url: url)
        }
        .overlay {
            if observable.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
                    .zIndex(1)
            }
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
