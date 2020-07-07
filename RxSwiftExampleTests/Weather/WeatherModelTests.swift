//
//  WeatherModelTests.swift
//  RxSwiftExampleTests
//
//  Created by Johnny Yen on 2020/7/1.
//  Copyright © 2020 Test. All rights reserved.
//

import XCTest

@testable import RxSwiftExample

class WeatherModelTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testWeatherInfoDecode() throws {
        guard let url = Bundle(for: type(of: self)).url(forResource: "TestWeatherData", withExtension: "json") else {
            XCTFail("Unable to get url for TestWeatherData.json")
            return
        }
        let testData = try Data(contentsOf: url)
        let weatherInfo = try JSONDecoder().decode(WeatherInfo.self, from: testData)

        XCTAssertEqual(weatherInfo.main.temp, 296.69)
        XCTAssertEqual(weatherInfo.main.feelsLike, 297.6)
        XCTAssertEqual(weatherInfo.wind.speed, 2.94)
        XCTAssertEqual(weatherInfo.weather.first?.main, "Clouds")
        XCTAssertEqual(weatherInfo.weather.first?.desc, "overcast clouds")
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
