//
//  Weather.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/27.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation

//"{\"coord\":{\"lon\":139,\"lat\":35},
//\"weather\":[{\"id\":500,\"main\":\"Rain\",\"description\":\"light rain\",\"icon\":\"10n\"}],
//\"base\":\"stations\",
//\"main\":{\"temp\":296.48,\"feels_like\":296.62,\"temp_min\":296.48,\"temp_max\":296.48,\"pressure\":1002,\"humidity\":65},
//\"wind\":{\"speed\":2.85,\"deg\":254},
//\"rain\":{\"1h\":0.88},
//\"clouds\":{\"all\":100},
//\"dt\":1593269522,
//\"sys\":{\"type\":3,\"id\":2019346,\"country\":\"JP\",\"sunrise\":1593199921,\"sunset\":1593252112},
//\"timezone\":32400,
//\"id\":1851632,
//\"name\":\"Shuzenji\",
//\"cod\":200}"

struct WeatherInfo: Decodable {
    let coordinate: Coordinate
    let weather: [Weather]
    let base: String
    let main: Main
    let wind: Wind
//    let rain: Rain
    let clouds: Clouds
    let dt: TimeInterval
    let sys: Sys
    let timezone: TimeInterval
    let id: Int
    let name: String
    let cod: Int

    enum CodingKeys: String, CodingKey {
        case coordinate = "coord"
        case weather
        case base
        case main
        case wind
//        case rain
        case clouds
        case dt
        case sys
        case timezone
        case id
        case name
        case cod
    }

    struct Coordinate: Decodable {
        let longitude: Double
        let latitude: Double

        enum CodingKeys: String, CodingKey {
            case longitude = "lon"
            case latitude = "lat"
        }
    }

    struct Weather: Decodable {
        let id: Int
        let main: String
        let desc: String
        let icon: String

        enum CodingKeys: String, CodingKey {
            case id
            case main
            case desc = "description"
            case icon
        }
    }

    struct Main: Decodable {
        let temp: Double
        let feelsLike: Double
        let pressure: Double
        let humidity: Double
        let tempMin: Double
        let tempMax: Double

        var temp_disp: String {
            return displayTemp(kelvin: temp)
        }

        var feelsLike_disp: String {
            return displayTemp(kelvin: feelsLike)
        }

        var tempMin_disp: String {
            return displayTemp(kelvin: tempMin)
        }

        var tempMax_disp: String {
            return displayTemp(kelvin: tempMax)
        }

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case pressure
            case humidity
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }

        private func displayTemp(kelvin: Double) -> String {
            let formatter = MeasurementFormatter()
            formatter.numberFormatter.maximumFractionDigits = 1
            formatter.unitStyle = .medium
            let input = Measurement(value: kelvin, unit: UnitTemperature.kelvin)

            return formatter.string(from: input)
        }
    }

    struct Wind: Decodable {
        let speed: Double
        let deg: Double
    }

    struct Rain: Decodable {
        let h1: Double

        enum CodingKeys: String, CodingKey {
            case h1 = "1h"
        }
    }

    struct Clouds: Decodable {
        let all: Int
    }

    struct Sys:Decodable {
        let type: Int
        let id: Int
        let country: String
        let sunrise: TimeInterval
        let sunset: TimeInterval
    }
}
