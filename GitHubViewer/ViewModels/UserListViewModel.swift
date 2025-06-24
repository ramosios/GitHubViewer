//
//  UserListViewModel.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import Foundation
import RxSwift
import RxCocoa

enum UserListLoadingState {
    case idle
    case loading
    case error(String)
}

class UserListViewModel {
    let selectedUser = PublishRelay<String>()
    private let service = GitHubService()

    let users = BehaviorRelay<[UserSummary]>(value: [])
    let loadingState = BehaviorRelay<UserListLoadingState>(value: .idle)

    func fetchUsers() -> Single<[UserSummary]> {
        loadingState.accept(.loading)

        return service.fetchUsers()
            .do(
                onSuccess: { [weak self] users in
                    self?.users.accept(users)
                    self?.loadingState.accept(.idle)
                },
                onError: { [weak self] error in
                    let message = (error as? URLError)?.localizedDescription ?? "Failed to fetch users"
                    self?.loadingState.accept(.error(message))
                }
            )
    }

    func fetchUserByUsername(_ login: String) -> Single<UserSummary> {
        loadingState.accept(.loading)

        return service.fetchUser(login: login)
            .do(
                onSuccess: { [weak self] user in
                    self?.users.accept([user])
                    self?.loadingState.accept(.idle)
                },
                onError: { [weak self] error in
                    let message = (error as? URLError)?.localizedDescription ?? "User not found"
                    self?.loadingState.accept(.error(message))
                }
            )
    }
}
