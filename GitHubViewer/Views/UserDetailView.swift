//
//  UserDetailView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI

struct UserDetailView: View {
    @StateObject private var observable: UserDetailBridge

    init(username: String) {
        _observable = StateObject(wrappedValue: UserDetailBridge(username: username))
    }

    var body: some View {
        Group {
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
                .padding()
            } else if observable.isLoading {
                ProgressView("Loading...")
            } else {
                Text("No user data")
            }
        }
        .navigationTitle("User Detail")
    }
}

