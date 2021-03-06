//
//  AddProfileTests.swift
//  RxSwiftExampleTests
//
//  Created by Johnny Yen on 2020/6/9.
//  Copyright © 2020 Test. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import CoreData

@testable import RxSwiftExample
class AddProfileTests: XCTestCase {

    private var viewModel: AddProfileViewModel!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    private var mockStorageService: StorageService!

    private var mockContainer: NSPersistentContainer!
    private var mockContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockContainer = getMockContainer()
        mockContext = mockContainer.newBackgroundContext()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        mockStorageService = StorageService(container: mockContainer, context: mockContext)
        viewModel = AddProfileViewModel(mockStorageService)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        disposeBag = nil
        scheduler = nil
        mockStorageService = nil
        mockContext = nil
        mockContainer = nil
        try super.tearDownWithError()
    }

    func testInputValidator() throws {
        let isValid = scheduler.createObserver(Bool.self)

        viewModel.isValid
            .bind(to: isValid)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(1, ""),
                                        .next(2, "Name")])
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(1, ""),
                                        .next(3, "Birthday")])
            .bind(to: viewModel.birthday)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(isValid.events, [.next(1, false), .next(2, false), .next(3, true)])
    }

    func testCreateProfile() throws {
        let mocServices = mockStorageService!

        let fetchExpectation = expectation(description: "")
        viewModel.didCreateProfile
            .flatMap { _ in mocServices.fetchAll() }
            .subscribe(onNext: {
                XCTAssertEqual($0.count, 1)
                fetchExpectation.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(1, "Test Name")])
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(2, "Test Birthday")])
            .bind(to: viewModel.birthday)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(3, Void())])
            .bind(to: viewModel.saveTap)
            .disposed(by: disposeBag)

        scheduler.start()

        wait(for: [fetchExpectation], timeout: 2)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

    private func getMockContainer() -> NSPersistentContainer{
        let container = NSPersistentContainer(name: "DataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )

            // Check if creating container wrong
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        return container
    }
}
