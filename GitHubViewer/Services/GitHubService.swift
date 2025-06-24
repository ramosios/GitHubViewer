//
//  GitHubService.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  This file defines the GitHubService class, responsible for performing API
//  requests to GitHub's REST API v3. It supports fetching users, user details,
//  and repositories using reactive RxSwift patterns.
//

import Foundation
import RxSwift
import RxCocoa

/// Protocol defining GitHub API interactions for abstraction and testability.
protocol GitHubServiceProtocol {
    func fetchUsers(since: Int, perPage: Int) -> Single<[UserSummary]>
    func fetchUserDetail(username: String) -> Single<UserDetail>
    func fetchRepositories(for username: String) -> Single<[Repository]>
    func fetchUser(login: String) -> Single<UserSummary>
}

/// Service class for interacting with GitHub REST API v3.
class GitHubService: GitHubServiceProtocol {
    private let baseURL = "https://api.github.com"
    private let session: URLSession
    private let decoder: JSONDecoder

    /// Retrieves the GitHub token from Info.plist if set.
    private var githubToken: String {
        Bundle.main.object(forInfoDictionaryKey: "GitHubToken") as? String ?? ""
    }

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    /// Creates an authorized GET request for GitHub API calls.
    /// - Parameter url: The URL to request.
    /// - Returns: A configured `URLRequest` with headers.
    private func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        if !githubToken.isEmpty {
            request.addValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// Executes a request and decodes the JSON response into a model.
    /// - Parameter request: A `URLRequest` object.
    /// - Returns: A `Single` emitting the decoded model or an error.
    private func perform<T: Decodable>(_ request: URLRequest) -> Single<T> {
        return session.rx.data(request: request)
            .map { [weak self] data in
                guard let self = self else { throw NetworkError.invalidURL }
                return try self.decoder.decode(T.self, from: data)
            }
            .asSingle()
    }

    /// Fetches a list of GitHub users.
    /// - Parameters:
    ///   - since: The user ID to start from (for pagination).
    ///   - perPage: Number of users per page.
    /// - Returns: A `Single` emitting an array of users.
    func fetchUsers(since: Int = 0, perPage: Int = 30) -> Single<[UserSummary]> {
        guard var urlComponents = URLComponents(string: "\(baseURL)/users") else {
            return .error(NetworkError.invalidURL)
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "since", value: "\(since)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url = urlComponents.url else {
            return .error(NetworkError.invalidURL)
        }

        return perform(authorizedRequest(url: url))
    }

    /// Fetches detailed profile data for a GitHub user.
    /// - Parameter username: The GitHub username.
    /// - Returns: A `Single` emitting the user's detail.
    func fetchUserDetail(username: String) -> Single<UserDetail> {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else {
            return .error(NetworkError.invalidURL)
        }

        return perform(authorizedRequest(url: url))
    }

    /// Fetches public repositories for a GitHub user, excluding forks.
    /// - Parameter username: The GitHub username.
    /// - Returns: A `Single` emitting the user's non-forked repositories.
    func fetchRepositories(for username: String) -> Single<[Repository]> {
        guard let url = URL(string: "\(baseURL)/users/\(username)/repos") else {
            return .error(NetworkError.invalidURL)
        }

        return perform(authorizedRequest(url: url))
            .map { (repos: [Repository]) in
                repos.filter { !$0.isFork }
            }
    }

    /// Fetches summary info for a GitHub user.
    /// - Parameter login: The GitHub username.
    /// - Returns: A `Single` emitting a brief user summary.
    func fetchUser(login: String) -> Single<UserSummary> {
        guard let url = URL(string: "\(baseURL)/users/\(login)") else {
            return .error(NetworkError.invalidURL)
        }

        return perform(authorizedRequest(url: url))
    }
}

/// Represents potential errors during GitHub API requests.
enum NetworkError: Error {
    case invalidURL
    case decoding(Error)
    case server(String)
}
