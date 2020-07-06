//
//  CurrentWeatherTests.swift
//  RxSwiftExampleTests
//
//  Created by Johnny Yen on 2020/7/1.
//  Copyright © 2020 Test. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
import RxTest
import RxBlocking

@testable import RxSwiftExample

class CurrentWeatherTests: XCTestCase {

    private var viewModel: CurrentWeatherViewModel<FakeLocationService, FakeAPIService>!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    override func setUpWithError() throws {
        try super.setUpWithError()
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        let bundle = Bundle(for: type(of: self))
        viewModel = CurrentWeatherViewModel(locationService: FakeLocationService(scheduler), apiService: FakeAPIService(bundle))
    }

    override func tearDownWithError() throws {
        viewModel = nil
        scheduler = nil
        disposeBag = nil
        try super.tearDownWithError()
    }

    func testDisplayCurrentLocality() throws {
        let localityExpectation = expectation(description: "expect current locality")
        viewModel.currentLocation
            .subscribe(onNext: {
                XCTAssertEqual($0, "Fake locality")
                localityExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [localityExpectation], timeout: 3)
    }

    func testCurrentTemp() throws {
        let currentTempExpectation = expectation(description: "expect current temp")
        viewModel.currentTemp
            .debug()
            .subscribe(onNext: {
                XCTAssertEqual($0, "74.4°F")
                currentTempExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [currentTempExpectation], timeout: 2)
    }

    func testWeatherDescription() throws {
        let weatherDescExpectation = expectation(description: "expect weather description")
        viewModel.weatherDesc
            .subscribe(onNext: {
                XCTAssertEqual($0, "overcast clouds")
                weatherDescExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [weatherDescExpectation], timeout: 2)
    }

    func testMinTemp() throws {
        let tempMinExpectation = expectation(description: "expect temp min")
        viewModel.tempMin
            .debug()
            .subscribe(onNext: {
                XCTAssertEqual($0, "74.4°F")
                tempMinExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [tempMinExpectation], timeout: 2)
    }

    func testMaxTemp() throws {
        let tempMaxExpectation = expectation(description: "expect temp max")
        viewModel.tempMax
            .debug()
            .subscribe(onNext: {
                XCTAssertEqual($0, "74.4°F")
                tempMaxExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [tempMaxExpectation], timeout: 2)
    }

    func testTempFeelsLike() throws {
        let tempFeelsLikeExpectation = expectation(description: "expect temp feels like")
        viewModel.tempFeelsLike
            .debug()
            .subscribe(onNext: {
                XCTAssertEqual($0, "76°F")
                tempFeelsLikeExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [tempFeelsLikeExpectation], timeout: 2)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

struct FakeLocationService: LocationServiceProtocol {

    private let scheduler: SchedulerType

    init(_ scheduler: SchedulerType) {
        self.scheduler = scheduler
    }

    func getCurrentPlacemark() -> Observable<Placemark> {
        return Observable.just(FakePlacemark())
    }
}

struct FakeAPIService: APIServiceProtocol {
    enum Errors: Error {
        case testDataFileNotFound
    }

    private var bundle: Bundle

    init(_ bundle: Bundle) {
        self.bundle = bundle
    }

    func getCurrentWeather(latitude: Double, longitude: Double) -> Observable<WeatherInfo> {
        return Observable.create { observer -> Disposable in
            if let url = self.bundle.url(forResource: "TestWeatherData", withExtension: "json") {
                do {
                    let testData = try Data(contentsOf: url)
                    let weatherInfo = try JSONDecoder().decode(WeatherInfo.self, from: testData)
                    observer.onNext(weatherInfo)
                } catch {
                    observer.onError(error)
                }
            } else {
                observer.onError(Errors.testDataFileNotFound)
            }

            return Disposables.create()
        }
    }
}

struct FakePlacemark: Placemark {
    var locality: String? {
        return "Fake locality"
    }

    var location: CLLocation? {
        return CLLocation(latitude:35, longitude: 121)
    }
}
