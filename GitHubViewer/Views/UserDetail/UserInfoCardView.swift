//
//  UserInfoCardView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI

struct UserInfoCardView: View {
    let user: UserDetail

    var body: some View {
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
}
