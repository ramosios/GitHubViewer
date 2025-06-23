//
//  Repository.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let isFork: Bool
    let htmlURL: String

    enum CodingKeys: String, CodingKey {
        case id, name, description, language, isFork = "fork"
        case stargazersCount = "stargazers_count"
        case htmlURL = "html_url"
    }
}
