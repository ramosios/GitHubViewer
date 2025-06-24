//
//  MockGitHubService.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 24/06/25.
//
import Foundation
import RxSwift
@testable import GitHubViewer

class MockGitHubService: GitHubServiceProtocol {
    var usersResult: Result<[UserSummary], Error>?
    var userDetailResult: Result<UserDetail, Error>?
    var reposResult: Result<[Repository], Error>?
    var userByLoginResult: Result<UserSummary, Error>?

    func fetchUsers(since: Int, perPage: Int) -> Single<[UserSummary]> {
        switch usersResult {
        case .success(let data): return .just(data)
        case .failure(let error): return .error(error)
        case .none: return .never()
        }
    }

    func fetchUserDetail(username: String) -> Single<UserDetail> {
        switch userDetailResult {
        case .success(let data): return .just(data)
        case .failure(let error): return .error(error)
        case .none: return .never()
        }
    }

    func fetchRepositories(for username: String) -> Single<[Repository]> {
        switch reposResult {
        case .success(let data): return .just(data)
        case .failure(let error): return .error(error)
        case .none: return .never()
        }
    }

    func fetchUser(login: String) -> Single<UserSummary> {
        switch userByLoginResult {
        case .success(let data): return .just(data)
        case .failure(let error): return .error(error)
        case .none: return .never()
        }
    }
}
