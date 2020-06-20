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
    private var mockStorageServices: StorageServices!

    lazy var mockContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )

            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()

    lazy var mockContext: NSManagedObjectContext = {
        self.mockContainer.newBackgroundContext()
    }()

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        mockStorageServices = StorageServices(container: mockContainer, context: mockContext)
        viewModel = AddProfileViewModel(mockStorageServices)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        disposeBag = nil
        scheduler = nil
        mockStorageServices = nil
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
        let mocServices = mockStorageServices!

        let fetchExpectation = expectation(description: "")
        viewModel.didCreateProfile
            .flatMap { mocServices.fetchAll() }
            .subscribe(onNext: {
                XCTAssertEqual($0.count, 1)
                fetchExpectation.fulfill()
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

}
