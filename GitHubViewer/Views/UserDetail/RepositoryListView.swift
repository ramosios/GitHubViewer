//
//  RepositoryListView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI

/// A view that displays a list of repositories for a user.
/// Each repository is selectable and triggers an action with its GitHub URL.
struct RepositoryListView: View {
    let repositories: [Repository]
    let onSelect: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title
            Text("Repositories")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            // Loop through each repository and display it as a tappable card
            ForEach(repositories, id: \.id) { repo in
                Button {
                    if let url = URL(string: repo.htmlURL) {
                        onSelect(url)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        // Repository name
                        Text(repo.name)
                            .font(.headline)

                        // Repository description
                        if let desc = repo.description {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // Language and star count
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
    }
}
