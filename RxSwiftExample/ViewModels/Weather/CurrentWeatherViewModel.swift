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

class CurrentWeatherViewModel<GenericLocationService: LocationServiceProtocol, GenericAPIService: APIServiceProtocol> {

    private var locationService: GenericLocationService
    private var apiService: GenericAPIService

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

    init(locationService: GenericLocationService, apiService: GenericAPIService) {
        self.locationService = locationService
        self.apiService = apiService

        let placemark = Observable.merge(.just(()), refreshLocation)
            .flatMap { locationService.getCurrentPlacemark().materialize() }
            .share()

        let placemarkElements = placemark.elements()
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .share()

        currentLocation = placemarkElements
            .map { $0.locality }
            .unwrap()
            .map { "\($0)" }

        let weatherInfoResult = placemarkElements
            .map { $0.location }
            .unwrap()
            .flatMap { apiService.getCurrentWeather(latitude: $0.coordinate.latitude,
                                                    longitude: $0.coordinate.longitude).materialize() }
            .share()

        let weatherInfo = weatherInfoResult.elements().share()

        currentTemp = weatherInfo
            .map { "\($0.main.temp_disp)" }

        weatherDesc = weatherInfo
            .map { $0.weather.first }
            .unwrap()
            .map { "\($0.desc)" }

        tempMin = weatherInfo
            .map { "\($0.main.tempMin_disp)" }

        tempMax = weatherInfo
            .map { "\($0.main.tempMax_disp)" }
        
        tempFeelsLike = weatherInfo
            .map { "\($0.main.feelsLike_disp)" }

        showError = Observable.merge(placemark.errors(), weatherInfoResult.errors())
            .map { $0.localizedDescription }
    }
}

extension CurrentWeatherViewModel where GenericLocationService == LocationService, GenericAPIService == APIService {
    convenience init() {
        self.init(locationService: LocationService(), apiService: APIService())
    }
}
