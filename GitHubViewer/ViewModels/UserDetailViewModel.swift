//
//  UserDetailViewModel.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import RxSwift
import RxCocoa

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

    // Dependency injection initializer
    init(service: GitHubServiceProtocol = GitHubService()) {
        self.service = service
    }

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
