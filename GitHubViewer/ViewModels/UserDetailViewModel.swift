//
//  UserDetailViewModel.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  View model for the User Detail screen. Handles fetching user profile and
//  repositories using a reactive pattern via RxSwift.
//

import RxSwift
import RxCocoa

/// Represents loading states for user detail or repositories.
enum UserDetailLoadingState: Equatable {
    case idle
    case loadingDetail
    case loadingRepos
    case error(String)
}

class UserDetailViewModel {
    private let service: GitHubServiceProtocol

    let userDetail = BehaviorRelay<UserDetail?>(value: nil)
    let repositories = BehaviorRelay<[Repository]>(value: [])
    let loadingState = BehaviorRelay<UserDetailLoadingState>(value: .idle)

    /// Initializes the view model with a GitHub service implementation.
    ///
    /// - Parameter service: A service conforming to `GitHubServiceProtocol`, defaults to `GitHubService`.
    init(service: GitHubServiceProtocol = GitHubService()) {
        self.service = service
    }

    /// Fetches profile data for the given GitHub username.
    ///
    /// - Parameter username: The GitHub username to look up.
    /// - Returns: A `Single<UserDetail>` that emits the user's detail or an error.
    func fetchUserDetail(username: String) -> Single<UserDetail> {
        loadingState.accept(.loadingDetail)

        return service.fetchUserDetail(username: username)
            .do(
                onSuccess: { [weak self] detail in
                    self?.userDetail.accept(detail)
                    self?.loadingState.accept(.idle)
                },
                onError: { [weak self] error in
                    let message = (error as? URLError)?.localizedDescription ?? "Failed to load user detail"
                    self?.loadingState.accept(.error(message))
                }
            )
    }

    /// Fetches non-forked public repositories for the specified user.
    ///
    /// - Parameter username: The GitHub username to fetch repositories for.
    /// - Returns: A `Single<[Repository]>` that emits a list of repositories or an error.
    func fetchRepositories(username: String) -> Single<[Repository]> {
        loadingState.accept(.loadingRepos)

        return service.fetchRepositories(for: username)
            .do(
                onSuccess: { [weak self] repos in
                    self?.repositories.accept(repos)
                    self?.loadingState.accept(.idle)
                },
                onError: { [weak self] error in
                    let message = (error as? URLError)?.localizedDescription ?? "Failed to load repositories"
                    self?.loadingState.accept(.error(message))
                }
            )
    }
}
