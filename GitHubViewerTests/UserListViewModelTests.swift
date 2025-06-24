//
//  UserListViewModelTests.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 24/06/25.
//
//  Unit tests for UserListViewModel using a mock GitHubService.
//

import Testing
import XCTest
import RxBlocking
import RxSwift
@testable import GitHubViewer

final class UserListViewModelTests: XCTestCase {
    var viewModel: UserListViewModel!
    var mockService: MockGitHubService!

    override func setUp() {
        super.setUp()
        mockService = MockGitHubService()
        viewModel = UserListViewModel(service: mockService)
    }

    /// Verifies users load successfully from the mock service and update observable state.
    func testFetchUsersSuccess() {
        let sampleUser = UserSummary(id: 1, login: "octocat", avatarURL: "url")
        mockService.usersResult = .success([sampleUser])

        _ = try? viewModel.fetchUsers().toBlocking().first()

        XCTAssertEqual(viewModel.users.value.count, 1)
        XCTAssertEqual(viewModel.users.value.first?.login, "octocat")
    }

    /// Verifies error state is set correctly when fetching users fails.
    func testFetchUsersFailure() {
        mockService.usersResult = .failure(URLError(.notConnectedToInternet))

        _ = viewModel.fetchUsers().toBlocking().materialize()

        if case .error(let message) = viewModel.loadingState.value {
            XCTAssertTrue(message.contains("Failed"))
        } else {
            XCTFail("Expected error state")
        }
    }

    /// Verifies user search by username populates user list and clears error.
    func testFetchUserByUsernameSuccess() {
        let user = UserSummary(id: 1, login: "octocat", avatarURL: "url")
        mockService.userByLoginResult = .success(user)

        _ = try? viewModel.fetchUserByUsername("octocat").toBlocking().first()

        XCTAssertEqual(viewModel.users.value.count, 1)
        XCTAssertEqual(viewModel.users.value.first?.login, "octocat")
    }

    /// Ensures error message is set when username lookup fails.
    func testFetchUserByUsernameFailure() {
        mockService.userByLoginResult = .failure(URLError(.badURL))

        _ = viewModel.fetchUserByUsername("missing").toBlocking().materialize()

        if case .error(let message) = viewModel.loadingState.value {
            XCTAssertTrue(message.contains("not found"))
        } else {
            XCTFail("Expected error state")
        }
    }
}
