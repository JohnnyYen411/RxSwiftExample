//
//  ProfileTests.swift
//  RxSwiftExampleTests
//
//  Created by Johnny Yen on 2020/6/17.
//  Copyright © 2020 Test. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import CoreData

@testable import RxSwiftExample

class ProfileTests: XCTestCase {

    private var viewModel: ProfileViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var mockStorageService: StorageService!
    private var mockContainer: NSPersistentContainer!
    private var mockContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockContainer = getMockContainer()
        mockContext = mockContainer.newBackgroundContext()
        scheduler = TestScheduler(initialClock: 0)
        mockStorageService = StorageService(container: mockContainer, context: mockContext)
        let profile = Profile(name: "Test Name", birthday: "Test Birthday")
        let provider = ProfileProvider(mockStorageService!, profile)
        viewModel = ProfileViewModel(provider)
        disposeBag = DisposeBag()
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

    func testProfile() throws {
        XCTAssertEqual(try viewModel.name.toBlocking().first(), "Test Name")
        XCTAssertEqual(try viewModel.birthday.toBlocking().first(), "Test Birthday")
    }

    func testToEdit() throws {
        let toEditName = scheduler.createObserver(String.self)
        let toEditBirthday = scheduler.createObserver(String.self)

        let toEdit = viewModel.toEditProfile.share()

        toEdit
            .flatMap { $0.name }
            .bind(to: toEditName)
            .disposed(by: disposeBag)

        toEdit
            .flatMap { $0.birthday }
            .bind(to: toEditBirthday)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(1, Void())])
            .bind(to: viewModel.tapEdit)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(toEditName.events, [.next(1, "Test Name")])
        XCTAssertEqual(toEditBirthday.events, [.next(1, "Test Birthday")])
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
