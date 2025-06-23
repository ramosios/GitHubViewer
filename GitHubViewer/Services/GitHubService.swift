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
    // Hard Coding Token to simplify running the project for evaluator
    private let githubToken = "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"

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

        let request = authorizedRequest(url: url)

        return session.rx.data(request: request)
            .map { [unowned self] data in
                try self.decoder.decode([UserSummary].self, from: data)
            }
            .asSingle()
    }

    func fetchUserDetail(username: String) -> Single<UserDetail> {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else {
            return .error(NetworkError.invalidURL)
        }

        let request = authorizedRequest(url: url)

        return session.rx.data(request: request)
            .map { [unowned self] data in
                try self.decoder.decode(UserDetail.self, from: data)
            }
            .asSingle()
    }

    func fetchRepositories(for username: String) -> Single<[Repository]> {
        guard let url = URL(string: "\(baseURL)/users/\(username)/repos") else {
            return .error(NetworkError.invalidURL)
        }

        let request = authorizedRequest(url: url)

        return session.rx.data(request: request)
            .map { [unowned self] data in
                let repos = try self.decoder.decode([Repository].self, from: data)
                return repos.filter { !$0.isFork }
            }
            .asSingle()
    }
}

enum NetworkError: Error {
    case invalidURL
}
