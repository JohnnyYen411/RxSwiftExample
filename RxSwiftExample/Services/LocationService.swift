//
//  LocationService.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/24.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import CoreLocation
import RxCoreLocation
import RxSwift

protocol LocationServiceProtocol {
    func getCurrentPlacemark() -> Observable<Placemark>
}

struct LocationService: LocationServiceProtocol {
    enum Errors: Error {
        case locationManager(Error)
        case authorization
    }

    let locationManager: CLLocationManager

    init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentPlacemark() -> Observable<Placemark> {
        let manager = locationManager

        return Observable.create { observer -> Disposable in
            let didChanged = manager.rx.didChangeAuthorization
                .map { $0.status }
            let authStatus = Observable.merge(.just(CLLocationManager.authorizationStatus()), didChanged)
                .share()

            let location = authStatus
                .filter { $0 == .authorizedAlways || $0 == .authorizedWhenInUse }
                .map { _ in manager.startMonitoringSignificantLocationChanges() }
                .flatMapLatest { _ in manager.rx.placemark }
                .map { $0 as Placemark }
                .do(onNext: { _ in manager.stopMonitoringSignificantLocationChanges() })
                .subscribe(observer)

            let managerError = manager.rx.didError
                .subscribe(onNext: { observer.onError(Errors.locationManager($0.error)) })
            let authError = authStatus
                .filter { $0 == .restricted || $0 == .denied }
                .subscribe(onNext: { _ in observer.onError(Errors.authorization) })

            return CompositeDisposable(managerError, authError, location)
        }
        .debug("get placemark")
    }
}

extension LocationService.Errors: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .locationManager(_): return "Unable to get current location"
        case .authorization: return "Location permission denied."
        }
    }
}

protocol Placemark {
    var locality: String? { get }
    var location: CLLocation? { get }
}

extension CLPlacemark: Placemark {  }
