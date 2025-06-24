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

    private let viewModel = UserDetailViewModel()
    private let disposeBag = DisposeBag()

    init(username: String) {
        bind()
        viewModel.fetchUserDetail(username: username)
    }

    private func bind() {
        viewModel.userDetail
            .subscribe(onNext: { [weak self] detail in
                self?.userDetail = detail
            })
            .disposed(by: disposeBag)

        viewModel.isLoading
            .subscribe(onNext: { [weak self] loading in
                self?.isLoading = loading
            })
            .disposed(by: disposeBag)
    }
}
