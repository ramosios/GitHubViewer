//
//  UserListView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI

struct UserListView: View {
    @StateObject private var observable = UserListBridge()

    var body: some View {
        NavigationStack {
            List(observable.users, id: \.id) { user in
                NavigationLink(value: user.login) {
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: user.avatarURL)) { image in
                            image.resizable()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.login)
                                .font(.headline)
                                .foregroundColor(.primary)
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
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .navigationTitle("GitHub Users")
            .navigationDestination(for: String.self) { username in
                UserDetailView(username: username)
            }
            .overlay {
                if observable.isLoading {
                    ProgressView("Loading...")
                }
            }
            .listStyle(.plain)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}
