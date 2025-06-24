//
//  UserListBridge.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import Foundation
import RxSwift
import RxCocoa

class UserListBridge: ObservableObject {
    @Published var users: [UserSummary] = []
    @Published var isLoading = false
    @Published var selectedUsername: String?
    @Published var searchText: String = ""
    @Published var errorMessage: String?

    private let viewModel = UserListViewModel()
    private let disposeBag = DisposeBag()

    init() {
        bind()
        viewModel.fetchUsers()
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bind() {
        viewModel.users
            .subscribe(onNext: { [weak self] users in
                DispatchQueue.main.async {
                    self?.users = users
                }
            })
            .disposed(by: disposeBag)

        viewModel.loadingState
            .subscribe(onNext: { [weak self] state in
                DispatchQueue.main.async {
                    switch state {
                    case .loading:
                        self?.isLoading = true
                        self?.errorMessage = nil
                    case .error(let msg):
                        self?.isLoading = false
                        self?.errorMessage = msg
                    case .idle:
                        self?.isLoading = false
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.selectedUser
            .subscribe(onNext: { [weak self] username in
                DispatchQueue.main.async {
                    self?.selectedUsername = username
                }
            })
            .disposed(by: disposeBag)
    }

    func search() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            viewModel.fetchUserByUsername(trimmed)
                .subscribe()
                .disposed(by: disposeBag)
        } else {
            viewModel.fetchUsers(reset: true)
                .subscribe()
                .disposed(by: disposeBag)
        }
    }

    func didSelect(user: UserSummary) {
        viewModel.selectedUser.accept(user.login)
    }

    func loadMoreIfNeeded(current user: UserSummary) {
        if let last = users.last, last.id == user.id {
            viewModel.fetchUsers()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
}
