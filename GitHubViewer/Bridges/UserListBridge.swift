//
//  UserListBridge.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  ObservableObject bridge connecting the UserListViewModel with SwiftUI views.
//  Manages reactive data flow for GitHub user listing, search, and navigation.
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

    /// Initializes the bridge and immediately fetches the first page of users.
    init() {
        bind()

        viewModel.fetchUsers()
            .subscribe()
            .disposed(by: disposeBag)
    }

    /// Binds the outputs of the view model to SwiftUI-friendly Published properties.
    private func bind() {
        // Bind user list updates
        viewModel.users
            .subscribe(onNext: { [weak self] users in
                DispatchQueue.main.async {
                    self?.users = users
                }
            })
            .disposed(by: disposeBag)

        // Reflect loading and error state changes in the view
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

        // React to user selection from within the view model
        viewModel.selectedUser
            .subscribe(onNext: { [weak self] username in
                DispatchQueue.main.async {
                    self?.selectedUsername = username
                }
            })
            .disposed(by: disposeBag)
    }

    /// Triggers a search for the username in `searchText`, or resets the user list if empty.
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

    /// Sends the selected user's login to the view model.
    /// - Parameter user: The selected `UserSummary`.
    func didSelect(user: UserSummary) {
        viewModel.selectedUser.accept(user.login)
    }

    /// Loads more users if the specified user is the last currently displayed.
    /// - Parameter user: The user currently being displayed.
    func loadMoreIfNeeded(current user: UserSummary) {
        if let last = users.last, last.id == user.id {
            viewModel.fetchUsers()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
}
