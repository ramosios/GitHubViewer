//
//  UserListView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import SwiftUI
import RxSwift
import RxCocoa

class UserListObservable: ObservableObject {
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
}

struct UserListView: View {
    @StateObject private var observable = UserListObservable()

    var body: some View {
        NavigationView {
            List(observable.users) { user in
                HStack {
                    AsyncImage(url: URL(string: user.avatarURL)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                    Text(user.login)
                        .font(.headline)
                }
            }
            .navigationTitle("GitHub Users")
            .overlay {
                if observable.isLoading {
                    ProgressView("Loading...")
                }
            }
        }
    }
}
