//
//  UserDetailViewModelTests.swift
//  GitHubViewerTests
//
//  Created by Jorge Ramos on 23/06/25.
//
//  Unit tests for UserDetailViewModel using a mock GitHub service.
//

import XCTest
import RxBlocking
import RxSwift
@testable import GitHubViewer

final class UserDetailViewModelTests: XCTestCase {
    var viewModel: UserDetailViewModel!
    var mockService: MockGitHubService!

    override func setUp() {
        super.setUp()
        mockService = MockGitHubService()
        viewModel = UserDetailViewModel(service: mockService)
    }

    /// Tests successful retrieval of user detail and correct state updates.
    func testFetchUserDetailSuccess() {
        let detail = UserDetail(login: "octocat", name: "The Octocat", avatarURL: "url", followers: 10, following: 5)
        mockService.userDetailResult = .success(detail)

        let result = try? viewModel.fetchUserDetail(username: "octocat").toBlocking().first()

        XCTAssertEqual(result?.login, "octocat")
        XCTAssertEqual(viewModel.userDetail.value?.name, "The Octocat")
        XCTAssertEqual(viewModel.loadingState.value, .idle)
    }

    /// Tests handling of a failed user detail fetch.
    func testFetchUserDetailFailure() {
        mockService.userDetailResult = .failure(URLError(.badServerResponse))

        _ = viewModel.fetchUserDetail(username: "fail").toBlocking().materialize()

        if case .error = viewModel.loadingState.value {
            XCTAssertTrue(true) // state correctly transitioned to error
        } else {
            XCTFail("Expected error state")
        }
    }

    /// Tests successful repository fetch and value assignment.
    func testFetchRepositoriesSuccess() {
        let repo = Repository(id: 1, name: "Hello", description: "A Swift repo", language: "Swift", stargazersCount: 10, isFork: false, htmlURL: "url")
        mockService.reposResult = .success([repo])

        let result = try? viewModel.fetchRepositories(username: "octocat").toBlocking().first()

        XCTAssertEqual(viewModel.repositories.value.count, 1)
        XCTAssertEqual(result?.first?.name, "Hello")
        XCTAssertEqual(viewModel.loadingState.value, .idle)
    }

    /// Tests handling of a failed repository fetch.
    func testFetchRepositoriesFailure() {
        mockService.reposResult = .failure(URLError(.timedOut))

        _ = viewModel.fetchRepositories(username: "fail").toBlocking().materialize()

        if case .error = viewModel.loadingState.value {
            XCTAssertTrue(true) // state correctly transitioned to error
        } else {
            XCTFail("Expected error state")
        }
    }
}
