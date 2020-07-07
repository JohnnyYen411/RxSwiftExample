//
//  APIServiceTests.swift
//  RxSwiftExampleTests
//
//  Created by Johnny Yen on 2020/6/27.
//  Copyright © 2020 Test. All rights reserved.
//

import XCTest
import RxSwift

@testable import RxSwiftExample

class APIServiceTests: XCTestCase {

    var apiService: APIService!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiService = APIService()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        apiService = nil
        disposeBag = nil
        try super.tearDownWithError()
    }

    func testGetCurrentWeather() throws {
        let currentWeatherExpectation = expectation(description: "current weather response")
        apiService.getCurrentWeather(latitude: 35, longitude: 121)
            .subscribe(onNext: { weatherInfo in
                XCTAssertNotEqual(weatherInfo.name.count, 0)
                currentWeatherExpectation.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        wait(for: [currentWeatherExpectation], timeout: 5)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
