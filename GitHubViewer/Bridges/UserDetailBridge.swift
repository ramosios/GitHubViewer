//
//  UserDetailBridge.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  Acts as an ObservableObject bridge between SwiftUI views and the underlying
//  UserDetailViewModel. It exposes published state properties for use in SwiftUI
//  and binds reactive RxSwift streams to them.
//

import RxSwift
import RxCocoa

class UserDetailBridge: ObservableObject {
    @Published var userDetail: UserDetail?
    @Published var isLoading = false
    @Published var repositories: [Repository] = []
    @Published var errorMessage: String?

    private let viewModel = UserDetailViewModel()
    private let disposeBag = DisposeBag()

    /// Initializes the bridge and triggers data fetch for the specified GitHub user.
    /// - Parameter username: The GitHub username to load details and repositories for.
    init(username: String) {
        bind()

        // Fetch user detail and repository list immediately on initialization
        viewModel.fetchUserDetail(username: username)
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.fetchRepositories(username: username)
            .subscribe()
            .disposed(by: disposeBag)
    }

    /// Binds ViewModel outputs to Published properties for use in SwiftUI views.
    private func bind() {
        // Update user detail when available
        viewModel.userDetail
            .subscribe(onNext: { [weak self] detail in
                DispatchQueue.main.async {
                    self?.userDetail = detail
                }
            })
            .disposed(by: disposeBag)

        // Update repositories list
        viewModel.repositories
            .subscribe(onNext: { [weak self] repos in
                DispatchQueue.main.async {
                    self?.repositories = repos
                }
            })
            .disposed(by: disposeBag)

        // Update loading state based on ViewModel events
        viewModel.loadingState
            .subscribe(onNext: { [weak self] state in
                DispatchQueue.main.async {
                    switch state {
                    case .loadingDetail, .loadingRepos:
                        self?.isLoading = true
                    default:
                        self?.isLoading = false
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
