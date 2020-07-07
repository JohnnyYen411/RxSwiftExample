//
//  EditProfileTests.swift
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

class EditProfileTests: XCTestCase {

    private var viewModel: EditProfileViewModel!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    private var mocStorageService: StorageService!
    private var mocContext: NSManagedObjectContext!
    private var mocContainer: NSPersistentContainer!
    private var profile: Profile!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        mocContainer = getMockContainer()
        mocContext = mocContainer.newBackgroundContext()
        mocStorageService = StorageService(container: mocContainer, context: mocContext)
        profile = Profile(name: "Test Name", birthday: "Test Birthday")
        let provider = ProfileProvider(mocStorageService, profile)
        viewModel = EditProfileViewModel(provider)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        disposeBag = nil
        scheduler = nil
        profile = nil
        try super.tearDownWithError()
    }

    func testProfileStartWithOriginal() throws {
        XCTAssertEqual(try viewModel.name.toBlocking().first(), "Test Name")
        XCTAssertEqual(try viewModel.birthday.toBlocking().first(), "Test Birthday")
    }

    func testProfileModified() throws {
        let isModified = scheduler.createObserver(Bool.self)

        viewModel.isModified
        .bind(to: isModified)
        .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(0, "Test Name"),
                                        .next(1, "Modified Name"),
                                        .next(3, ""),
                                        .next(5, "Modified Name")])
            .bind(to: viewModel.inputName)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(0, "Test Birthday"),
                                        .next(2, ""),
                                        .next(4, "Modified Birthday")])
            .bind(to: viewModel.inputBirthday)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(isModified.events, [.next(0, false), .next(1, true), .next(2, false), .next(3, false), .next(4, false), .next(5, true)])
    }

    func testSaveProfile() throws {
        let name = scheduler.createObserver(String.self)
        let birthday = scheduler.createObserver(String.self)
        let mocServices = mocStorageService!
        let profile = self.profile!

        viewModel.name
            .bind(to: name)
            .disposed(by: disposeBag)

        viewModel.birthday
            .bind(to: birthday)
            .disposed(by: disposeBag)

        let fetchExpectation = expectation(description: "Check profile modified")
        viewModel.didSave
            .flatMap { mocServices.fetch(uuid: profile.getUuid()) }
            .subscribe(onNext: {
                XCTAssertEqual($0.name, "Modified Name")
                XCTAssertEqual($0.birthday, "Modified Birthday")
                fetchExpectation.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(0, ())])
            .flatMap { mocServices.insert(profile: profile) }
            .subscribe()
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(1, "Modified Name")])
            .bind(to: viewModel.inputName)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(1, "Modified Birthday")])
            .bind(to: viewModel.inputBirthday)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(2, Void())])
            .bind(to: viewModel.saveTap)
            .disposed(by: disposeBag)

        scheduler.start()

        wait(for: [fetchExpectation], timeout: 2)
        XCTAssertEqual(name.events, [.next(0, "Test Name"), .next(2, "Modified Name")])
        XCTAssertEqual(birthday.events, [.next(0, "Test Birthday"), .next(2, "Modified Birthday")])

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
