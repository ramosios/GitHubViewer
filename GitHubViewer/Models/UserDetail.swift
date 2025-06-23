//
//  UserDetail.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
struct UserDetail: Codable {
    let login: String
    let name: String?
    let avatarURL: String
    let followers: Int
    let following: Int

    enum CodingKeys: String, CodingKey {
        case login, name, followers, following
        case avatarURL = "avatar_url"
    }
}
