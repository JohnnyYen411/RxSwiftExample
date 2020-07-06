//
//  StorageServiceTests.swift
//  RxSwiftExampleTests
//
//  Created by Johnny Yen on 2020/6/20.
//  Copyright © 2020 Test. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import CoreData

@testable import RxSwiftExample

class StorageServiceTests: XCTestCase {

    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var mockStorageService: StorageService!
    private var mockContext: NSManagedObjectContext!
    private var mockContainer: NSPersistentContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 1)
        disposeBag = DisposeBag()
        mockContainer = getMockContainer()
        mockContext = mockContainer.newBackgroundContext()
        mockStorageService = StorageService(container: mockContainer, context: mockContext)

    }

    override func tearDownWithError() throws {
        mockStorageService = nil
        mockContext = nil
        mockContainer = nil
        scheduler = nil
        disposeBag = nil
        try super.tearDownWithError()
    }

    func testFetchAll() throws {
        let inserted = scheduler.createObserver(Profile.self)
        let mockServices = mockStorageService!

        let fetchExpectation = expectation(description: "")
        scheduler.createColdObservable([.next(4, ())])
            .flatMap { mockServices.fetchAll() }
            .subscribe(onNext: { profiles in
                XCTAssertEqual(profiles.count, 3)
                fetchExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(1, ()),
                                        .next(2, ()),
                                        .next(3, ())])
            .flatMap { mockServices.insert(profile: Profile(name: "Test Name", birthday: "Test Birthday")) }
            .subscribe(onNext: {
                inserted.onNext($0)
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        scheduler.start()

        wait(for: [fetchExpectation], timeout: 2)
        XCTAssertEqual(inserted.events.count, 3)
    }

    func testInsertAndFetch() throws {
        let mockServices = mockStorageService!

        let profile = Profile(name: "Test Name", birthday: "Test Birthday")

        let fetchExpectation = expectation(description: "")
        scheduler.createColdObservable([.next(1, ())])
            .flatMap { mockServices.insert(profile: profile) }
            .flatMap { _ in mockServices.fetch(uuid: profile.getUuid()) }
            .subscribe(onNext: { profile in
                XCTAssertEqual(profile.name, "Test Name")
                XCTAssertEqual(profile.birthday, "Test Birthday")
                fetchExpectation.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        scheduler.start()

        wait(for: [fetchExpectation], timeout: 2)
    }

    func testUpdate() throws {
        let mockServices = mockStorageService!

        let profile = Profile(name: "Original Name", birthday: "Original Birthday")

        let fetchExpectation = expectation(description: "Check profile has been modified")
        scheduler.createColdObservable([.next(1, ())])
            .flatMap { mockServices.insert(profile: profile) }
            .flatMap { _ in mockServices.write(uuid: profile.getUuid(), name: "Modified Name", birthday: "Modified Birthday") }
            .flatMap { _ in mockServices.fetch(uuid: profile.getUuid()) }
            .subscribe(onNext: { profile in
                XCTAssertEqual(profile.name, "Modified Name")
                XCTAssertEqual(profile.birthday, "Modified Birthday")
                fetchExpectation.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        scheduler.start()

        wait(for: [fetchExpectation], timeout: 2)
    }

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
                XCTFail("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }
}
