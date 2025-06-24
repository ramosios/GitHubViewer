//
//  UserListView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  Displays a scrollable and searchable list of GitHub users.
//  Each item can be tapped to view detailed profile information.
//

import SwiftUI

struct UserListView: View {
    @StateObject private var observable = UserListBridge()

    var body: some View {
        NavigationStack {
            VStack {
                // Show centered error message when no users are loaded
                if observable.users.isEmpty && !observable.isLoading && observable.errorMessage != nil {
                    Spacer()
                    Text(observable.errorMessage ?? "")
                        .foregroundColor(.red)
                        .padding()
                        .accessibilityIdentifier("ErrorMessage")
                    Spacer()
                } else {
                    // Main user list
                    List(observable.users, id: \.id) { user in
                        NavigationLink(value: user.login) {
                            HStack(spacing: 16) {
                                // User avatar
                                AsyncImage(url: URL(string: user.avatarURL)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Circle().fill(Color.gray.opacity(0.3))
                                }
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .accessibilityIdentifier("UserAvatar_\(user.id)")

                                // Username text
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.login)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .accessibilityIdentifier("UserLogin_\(user.id)")
                                }

                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .onAppear {
                                // Trigger pagination when the last user appears
                                observable.loadMoreIfNeeded(current: user)
                            }
                        }
                        .accessibilityIdentifier("UserRow_\(user.id)")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .background(Color(UIColor.systemGroupedBackground))
                    .accessibilityIdentifier("UserList")
                }

                // Inline error message (e.g. after a search failure)
                if let error = observable.errorMessage, !observable.users.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 4)
                        .accessibilityIdentifier("InlineErrorMessage")
                }
            }
            .navigationTitle("GitHub Users")

            // Navigate to detail view when a username is selected
            .navigationDestination(for: String.self) { username in
                UserDetailView(username: username)
            }

            // Global loading spinner overlay
            .overlay {
                if observable.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                        .accessibilityIdentifier("LoadingIndicator")
                }
            }

            // Search bar for username filtering
            .searchable(text: $observable.searchText, prompt: "Search username")
            .onChange(of: observable.searchText) {
                observable.search()
            }
            .accessibilityIdentifier("UserListView")
        }
    }
}
