//
//  UserListBridge.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
import Combine
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
    private var cancellables = Set<AnyCancellable>()

    init() {
        bind()
        observeSearch()
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

    private func observeSearch() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.viewModel.fetchUsers()
                        .subscribe()
                        .disposed(by: self.disposeBag)
                }
            }
            .store(in: &cancellables)
    }

    func search() {
        if !searchText.isEmpty {
            viewModel.fetchUserByUsername(searchText)
                .subscribe()
                .disposed(by: disposeBag)
        }
    }

    func didSelect(user: UserSummary) {
        viewModel.selectedUser.accept(user.login)
    }
}
