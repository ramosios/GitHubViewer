//
//  UserInfoCardView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  Displays a user profile card showing avatar, username, name, and follower stats.
//

import SwiftUI

struct UserInfoCardView: View {
    let user: UserDetail

    var body: some View {
        VStack(spacing: 12) {
            // User avatar
            AsyncImage(url: URL(string: user.avatarURL)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())

            // GitHub login
            Text(user.login)
                .font(.title2)
                .fontWeight(.bold)

            // Optional full name
            if let name = user.name {
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Followers and following counts
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
}
