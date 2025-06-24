//
//  RepositoryListView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI

struct RepositoryListView: View {
    let repositories: [Repository]
    let onSelect: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Repositories")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            ForEach(repositories, id: \.id) { repo in
                Button {
                    if let url = URL(string: repo.htmlURL) {
                        onSelect(url)
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
    }
}
