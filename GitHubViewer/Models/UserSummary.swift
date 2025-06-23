//
//  UserSummary.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
struct UserSummary: Codable, Identifiable {
    let id: Int
    let login: String
    let avatarURL: String

    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarURL = "avatar_url"
    }
}
