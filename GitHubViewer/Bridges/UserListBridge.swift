//
//  UserListBridge.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI
import RxSwift
import RxCocoa
import Combine

class UserListBridge: ObservableObject {
    @Published var users: [UserSummary] = []
    @Published var isLoading = false
    @Published var selectedUsername: String?
    @Published var searchText: String = ""

    private let viewModel = UserListViewModel()
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    init() {
        bind()
        observeSearch()
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

        viewModel.selectedUser
            .subscribe(onNext: { [weak self] username in
                self?.selectedUsername = username
            })
            .disposed(by: disposeBag)
    }

    private func observeSearch() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.viewModel.fetchUsers()
                }
            }
            .store(in: &cancellables)
    }

    func search() {
        if !searchText.isEmpty {
            viewModel.fetchUserByUsername(searchText)
        }
    }

    func didSelect(user: UserSummary) {
        viewModel.selectedUser.accept(user.login)
    }
}
