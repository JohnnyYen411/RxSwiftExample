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

struct LocationService {
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

    func getCurrentPlacemark() -> Observable<CLPlacemark> {
        let manager = locationManager

        return Observable.create { observer -> Disposable in
            let didChanged = manager.rx.didChangeAuthorization
                .map { $0.status }
            let authStatus = Observable.merge(.just(CLLocationManager.authorizationStatus()), didChanged)
                .share(replay: 1)

            let location = authStatus
                .filter { $0 == .authorizedAlways || $0 == .authorizedWhenInUse }
                .map { _ in manager.startUpdatingLocation() }
                .flatMap { _ in manager.rx.placemark }
                .do(onNext: { _ in manager.stopUpdatingLocation() })
                .subscribe(observer)

            let managerError = manager.rx.didError
                .subscribe(onNext: { observer.onError(Errors.locationManager($0.error)) })
            let authError = authStatus
                .filter { $0 == .restricted || $0 == .denied }
                .subscribe(onNext: { _ in observer.onError(Errors.authorization) })

            return CompositeDisposable(managerError, authError, location)
        }
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
