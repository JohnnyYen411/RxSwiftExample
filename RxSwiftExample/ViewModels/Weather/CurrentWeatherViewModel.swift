//
//  CurrentWeatherViewModel.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/8.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

class CurrentWeatherViewModel {
    private let locationServices: LocationService

    //Inputs
    let refreshLocation = PublishSubject<Void>()

    //Outputs
    let currentLocation: Observable<String>
    let currentTemp: Observable<String>
    let weatherDesc: Observable<String>
    let tempMin: Observable<String>
    let tempMax: Observable<String>
    let tempFeelsLike: Observable<String>

    let showError: Observable<String>

    init() {
        let services = LocationService()
        locationServices = services

        let refresh = refreshLocation
            .share(replay: 1)

        let placemark = Observable.merge(.just(()), refresh)
            .flatMap { services.getCurrentPlacemark().materialize() }
            .share()

        let placemarkElements = placemark.elements().share(replay: 1)
        currentLocation = placemarkElements
            .filter { $0.locality != nil }
            .map { $0.locality! }
            .map { "\($0)" }

        let weatherInfo = placemarkElements
            .map { $0.location }
            .filter { $0 != nil }
            .map { $0! }
            .flatMap { APIService().getCurrentWeather(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .share(replay: 1)

        currentTemp = weatherInfo
            .map { "\($0.main.temp_disp)" }
        weatherDesc = weatherInfo
            .map { $0.weather.first }
            .filter { $0 != nil }
            .map { $0! }
            .map { "\($0.desc)" }
        tempMin = weatherInfo
            .map { "\($0.main.tempMin_disp)" }
        tempMax = weatherInfo
            .map { "\($0.main.tempMax_disp)" }
        tempFeelsLike = weatherInfo
            .map { "\($0.main.feelsLike_disp)" }

        showError = placemark.errors()
            .map { $0.localizedDescription }
    }
}
