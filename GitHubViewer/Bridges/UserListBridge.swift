//
//  UserListBridge.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI
import RxSwift
import RxCocoa

class UserListBridge: ObservableObject {
    @Published var selectedUsername: String?
    @Published var users: [UserSummary] = []
    @Published var isLoading = false

    private let viewModel = UserListViewModel()
    private let disposeBag = DisposeBag()

    init() {
        bind()
        viewModel.fetchUsers()
    }

    private func bind() {
        viewModel.users
            .subscribe(onNext: { [weak self] users in
                self?.users = users
            })
            .disposed(by: disposeBag)

        viewModel.isLoading
            .subscribe(onNext: { [weak self] loading in
                self?.isLoading = loading
            })
            .disposed(by: disposeBag)
    }
    func didSelect(user: UserSummary) {
        viewModel.selectedUser.accept(user.login)
    }
}
