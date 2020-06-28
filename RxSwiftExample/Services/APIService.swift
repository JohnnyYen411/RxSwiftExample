//
//  APIService.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/27.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

struct APIService {

    private let apiKey = "OpenWeatherMap API key"

    func getCurrentWeather(latitude: Double, longitude: Double) -> Observable<WeatherInfo> {
        return Observable.create { observer -> Disposable in
            let requestMgr = RequestManager()
            requestMgr.queryParam.add(key: "lat", value: "\(latitude)")
            requestMgr.queryParam.add(key: "lon", value: "\(longitude)")
            requestMgr.queryParam.add(key: "appid", value: self.apiKey)
            requestMgr.request(urlString: "https://api.openweathermap.org/data/2.5/weather") { result in
                if let error = result.error {
                    observer.onError(error)
                }

                let decoder = JSONDecoder()
                do {
                    if let data = result.data,
                       let weatherInfo = try decoder.decode(WeatherInfo?.self, from: data) {
//                        let dataStr = String(data: data, encoding: .utf8)
//                        print("data: \(String(describing: dataStr))")
                        observer.onNext(weatherInfo)
                    }
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
    }
}
