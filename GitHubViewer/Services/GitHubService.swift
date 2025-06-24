//
//  GitHubService.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import Foundation
import RxSwift
import RxCocoa

class GitHubService {
    private let baseURL = "https://api.github.com"
    private let session: URLSession
    private let decoder: JSONDecoder

    private var githubToken: String {
        Bundle.main.object(forInfoDictionaryKey: "GitHubToken") as? String ?? ""
    }

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    private func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) -> Single<T> {
        return session.rx.data(request: request)
            .map { [weak self] data in
                guard let self = self else { throw NetworkError.invalidURL }
                return try self.decoder.decode(T.self, from: data)
            }
            .asSingle()
    }

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

    func fetchUserDetail(username: String) -> Single<UserDetail> {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else {
            return .error(NetworkError.invalidURL)
        }

        return perform(authorizedRequest(url: url))
    }

    func fetchRepositories(for username: String) -> Single<[Repository]> {
        guard let url = URL(string: "\(baseURL)/users/\(username)/repos") else {
            return .error(NetworkError.invalidURL)
        }

        return perform(authorizedRequest(url: url))
            .map { (repos: [Repository]) in
                repos.filter { !$0.isFork }
            }
    }

    func fetchUser(login: String) -> Single<UserSummary> {
        guard let url = URL(string: "\(baseURL)/users/\(login)") else {
            return .error(NetworkError.invalidURL)
        }

        return perform(authorizedRequest(url: url))
    }
}

enum NetworkError: Error {
    case invalidURL
    case decoding(Error)
    case server(String)
}
