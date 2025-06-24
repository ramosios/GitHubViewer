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

                // MARK: - User Info
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
                            .fontWeight(.bold)

                        if let name = user.name {
                            Text(name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 16) {
                            Label("\(user.followers)", systemImage: "person.2.fill")
                            Label("\(user.following)", systemImage: "person.crop.circle.fill.badge.checkmark")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 1)
                }

                // MARK: - Repositories
                if !observable.repositories.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Repositories")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                } else if observable.isLoading {
                    ProgressView("Loading Repositories...")
                        .padding()
                } else {
                    Text("No public repositories found.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
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

