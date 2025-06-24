//
//  UserListViewModel.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  View model for the GitHub user list screen. Handles paginated user loading,
//  state management, and username-based lookup using reactive bindings.
//

import Foundation
import RxSwift
import RxCocoa

/// Represents the loading state for the user list.
enum LoadingState {
    case idle
    case loading
    case error(String)
}

class UserListViewModel {
    private let service: GitHubServiceProtocol
    private let disposeBag = DisposeBag()
    let users = BehaviorRelay<[UserSummary]>(value: [])
    let loadingState = BehaviorRelay<LoadingState>(value: .idle)
    let selectedUser = PublishRelay<String>()

    private var lastUserID: Int = 0
    private var isFetching = false
    private var lastFetchTime = Date.distantPast
    private let throttleInterval: TimeInterval = 0.75

    /// Initializes the view model with a GitHub service dependency.
    init(service: GitHubServiceProtocol = GitHubService()) {
        self.service = service
    }

    /// Fetches a paginated list of GitHub users.
    /// - Parameter reset: If true, clears the current list before loading.
    /// - Returns: A `Completable` that signals completion or error.
    func fetchUsers(reset: Bool = false) -> Completable {
        let now = Date()
        guard !isFetching, now.timeIntervalSince(lastFetchTime) > throttleInterval else {
            return .empty()
        }

        if reset { lastUserID = 0 }
        isFetching = true
        lastFetchTime = now
        loadingState.accept(.loading)

        return service.fetchUsers(since: lastUserID, perPage: 30)
            .do(
                onSuccess: { [weak self] newUsers in
                    guard let self else { return }
                    self.lastUserID = newUsers.last?.id ?? self.lastUserID
                    if reset {
                        self.users.accept(newUsers)
                    } else {
                        self.users.accept(self.users.value + newUsers)
                    }
                    self.loadingState.accept(.idle)
                    self.isFetching = false
                },
                onError: { [weak self] _ in
                    self?.loadingState.accept(.error("Failed to fetch users"))
                    self?.isFetching = false
                }
            )
            .asCompletable()
    }

    /// Fetches a single user by GitHub login name.
    /// - Parameter login: GitHub username.
    /// - Returns: A `Completable` indicating success or failure.
    func fetchUserByUsername(_ login: String) -> Completable {
        loadingState.accept(.loading)
        return service.fetchUser(login: login)
            .do(
                onSuccess: { [weak self] user in
                    self?.users.accept([user])
                    self?.loadingState.accept(.idle)
                },
                onError: { [weak self] _ in
                    self?.loadingState.accept(.error("User not found"))
                }
            )
            .asCompletable()
    }
}
