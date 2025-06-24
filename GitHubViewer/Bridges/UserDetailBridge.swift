//
//  UserDetailBridge.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
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

    init(username: String) {
        bind()
        viewModel.fetchUserDetail(username: username)
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.fetchRepositories(username: username)
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bind() {
        viewModel.userDetail
            .subscribe(onNext: { [weak self] detail in
                DispatchQueue.main.async {
                    self?.userDetail = detail
                }
            })
            .disposed(by: disposeBag)

        viewModel.repositories
            .subscribe(onNext: { [weak self] repos in
                DispatchQueue.main.async {
                    self?.repositories = repos
                }
            })
            .disposed(by: disposeBag)

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
