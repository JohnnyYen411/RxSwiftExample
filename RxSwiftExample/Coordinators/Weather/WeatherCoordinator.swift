//
//  WeatherCoordinator.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/8.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

class WeatherCoordinator: Coordinator<Void> {
    override func start(type: CoordinatorTransitionType = .push) -> Observable<Void> {
        let vc = CurrentWeatherViewController.instantiate(from: .weather)

        let didPop = navigationController.rx.willShow
            .filter { (viewController, _) -> Bool in viewController != vc }
            .filter { [weak self] (viewController, _) -> Bool in !(self?.navigationController.viewControllers.contains(vc) ?? false) }
            .map { _ in () }

        navigationController.pushViewController(vc, animated: true)

        return didPop
    }
}
