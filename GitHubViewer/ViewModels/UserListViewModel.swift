//
//  UserListViewModel.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import Foundation
import RxSwift
import RxCocoa

class UserListViewModel {
    let selectedUser = PublishRelay<String>() // Emits username (login) when selected
    private let service = GitHubService()
    private let disposeBag = DisposeBag()

    // Outputs
    let users = BehaviorRelay<[UserSummary]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<String>()

    func fetchUsers() {
        isLoading.accept(true)
        service.fetchUsers()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] users in
                    self?.users.accept(users)
                    self?.isLoading.accept(false)
                },
                onFailure: { [weak self] error in
                    self?.error.accept("Failed to fetch users")
                    self?.isLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    func fetchUserByUsername(_ login: String) {
        isLoading.accept(true)
        service.fetchUser(login: login)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] user in
                    self?.users.accept([user]) // replace list with single result
                    self?.isLoading.accept(false)
                },
                onFailure: { [weak self] _ in
                    self?.error.accept("User not found")
                    self?.isLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
}
