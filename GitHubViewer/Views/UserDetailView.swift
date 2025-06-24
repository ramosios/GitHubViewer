//
//  UserDetailView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI
import WebKit

struct UserDetailView: View {
    @StateObject private var observable: UserDetailBridge
    @State private var selectedRepoURL: URL?

    init(username: String) {
        _observable = StateObject(wrappedValue: UserDetailBridge(username: username))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let user = observable.userDetail {
                    VStack(spacing: 12) {
                        AsyncImage(url: URL(string: user.avatarURL)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())

                        Text(user.login)
                            .font(.title2)
                            .bold()

                        if let name = user.name {
                            Text(name).font(.subheadline)
                        }

                        HStack {
                            Text("Followers: \(user.followers)")
                            Text("Following: \(user.following)")
                        }
                        .font(.caption)
                    }
                }

                if !observable.repositories.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Repositories")
                            .font(.title3)
                            .bold()
                            .padding(.top)

                        ForEach(observable.repositories, id: \.id) { repo in
                            Button {
                                if let url = URL(string: repo.htmlURL) {
                                    selectedRepoURL = url
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(repo.name)
                                        .font(.headline)

                                    if let desc = repo.description {
                                        Text(desc)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    HStack(spacing: 16) {
                                        if let lang = repo.language {
                                            Label(lang, systemImage: "chevron.left.slash.chevron.right")
                                        }
                                        Label("\(repo.stargazersCount)", systemImage: "star.fill")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else if observable.isLoading {
                    ProgressView("Loading Repositories...")
                } else {
                    Text("No public repositories found.")
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            .padding()
        }
        .navigationTitle("User Detail")
        .sheet(item: $selectedRepoURL) { url in
            WebViewer(url: url)
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}
