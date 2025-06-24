//
//  UserDetailViewModel.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import Foundation
import RxSwift
import RxCocoa

class UserDetailViewModel {
    let repositories = BehaviorRelay<[Repository]>(value: [])
    private let service = GitHubService()
    private let disposeBag = DisposeBag()

    let userDetail = BehaviorRelay<UserDetail?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<String>()

    func fetchUserDetail(username: String) {
        isLoading.accept(true)
        service.fetchUserDetail(username: username)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] detail in
                    self?.userDetail.accept(detail)
                    self?.isLoading.accept(false)
                },
                onFailure: { [weak self] err in
                    self?.error.accept("Failed to load user detail")
                    self?.isLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    func fetchRepositories(username: String) {
        service.fetchRepositories(for: username)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] repos in
                    self?.repositories.accept(repos)
                },
                onFailure: { [weak self] _ in
                    self?.error.accept("Failed to load repositories")
                }
            )
            .disposed(by: disposeBag)
    }
}
