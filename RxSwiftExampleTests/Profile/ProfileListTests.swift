//
//  ProfileListTests.swift
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

class ProfileListTests: XCTestCase {

    private var viewModel: ProfileListViewModel!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    private var mockStorageService: StorageService!
    private var mockContainer: NSPersistentContainer!
    private var mockContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 0)
        mockContainer = getMockContainer()
        mockContext = mockContainer.newBackgroundContext()
        mockStorageService = StorageService(container: mockContainer, context: mockContext)
        viewModel = ProfileListViewModel(mockStorageService)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        scheduler = nil
        disposeBag = nil
        mockStorageService = nil
        mockContext = nil
        mockContainer = nil
        try super.tearDownWithError()
    }

    func testListStartEmpty() throws {
        XCTAssertEqual(try viewModel.profileList.toBlocking().first()!.count, 0)
        XCTAssertEqual(try viewModel.hasItems.toBlocking().first(), false)
    }

    func testToAddProfile() throws {
        let toAdd = scheduler.createObserver(Void.self)

        viewModel.toAddProfile
            .bind(to: toAdd)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(1, Void())])
            .bind(to: viewModel.toAddProfile)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(toAdd.events.count, 1)
    }

    
    func testDidAddProfile() throws {
        let latestName = scheduler.createObserver(String.self)
        let latestBirthday = scheduler.createObserver(String.self)
        let didFetchList = scheduler.createObserver(Void.self)

        let lastProvider = viewModel.profileList
            .map { $0.last }
            .unwrap()
            .share()

        let createdExpectation = expectation(description: "profile created")
        lastProvider
            .subscribe(onNext: { _ in createdExpectation.fulfill() })
            .disposed(by: disposeBag)

        lastProvider
            .flatMap { $0.name }
            .bind(to: latestName)
            .disposed(by: disposeBag)

        lastProvider
            .flatMap { $0.birthday }
            .bind(to: latestBirthday)
            .disposed(by: disposeBag)

        viewModel.didUpdateList
            .bind(to: didFetchList)
            .disposed(by: disposeBag)

        mockStorageService.insert(profile: Profile(name: "Test Name", birthday: "Test Birthday"))
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.createProfile.onNext(())
                }, onError: { error in
                    XCTAssertNil(error)
            })
            .disposed(by: disposeBag)

        wait(for: [createdExpectation], timeout: 2)
        XCTAssertEqual(latestName.events.last?.value.element, "Test Name")
        XCTAssertEqual(latestBirthday.events.last?.value.element, "Test Birthday")
        XCTAssertEqual(didFetchList.events.count, 2)
    }

//    func testClearAll() throws {
//        let providers = scheduler.createObserver([ProfileProvider].self)
//        let hasItems = scheduler.createObserver(Bool.self)
//        let didClear = scheduler.createObserver(Void.self)
//        let didCreate = scheduler.createObserver(Void.self)
//
//        viewModel.profileList
//            .bind(to: providers)
//            .disposed(by: disposeBag)
//
//        viewModel.hasItems
//            .bind(to: hasItems)
//            .disposed(by: disposeBag)
//
//        viewModel.didUpdateList
//            .bind(to: didCreate)
//            .disposed(by: disposeBag)
//
//        viewModel.didClear
//            .bind(to: didClear)
//            .disposed(by: disposeBag)
//
//        scheduler.createColdObservable([.next(1, ())])
//            .bind(to: viewModel.createProfile)
//            .disposed(by: disposeBag)
//
//        scheduler.createColdObservable([.next(2, Void())])
//            .bind(to: viewModel.clearTap)
//            .disposed(by: disposeBag)
//
//        scheduler.start()
//
//        XCTAssertEqual(hasItems.events, [.next(0, false), .next(1, true), .next(2, false)])
//        XCTAssertEqual(providers.events.last?.value.element!.count, 0)
//        XCTAssertEqual(didCreate.events.count, 1)
//        XCTAssertEqual(didClear.events.count, 1)
//    }

    func testProfileSelected() throws {
        let providerName = scheduler.createObserver(String.self)
        let providerBirthday = scheduler.createObserver(String.self)

        let selected = viewModel.toProfile.share()
        selected
            .flatMap { $0.name }
            .bind(to: providerName)
            .disposed(by: disposeBag)

        selected
            .flatMap { $0.birthday }
            .bind(to: providerBirthday)
            .disposed(by: disposeBag)

        let newProfile = Profile(name: "Test Name", birthday: "Test Birthday")
        let newProvider = ProfileProvider(mockStorageService!, newProfile)

        scheduler.createColdObservable([.next(1, newProvider)])
            .bind(to: viewModel.toProfile)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(providerName.events, [.next(1, "Test Name")])
        XCTAssertEqual(providerBirthday.events, [.next(1, "Test Birthday")])
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
