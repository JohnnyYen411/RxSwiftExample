//
//  MainCoordinator.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/8.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

class MainCoordinator: Coordinator<Void> {
    override func start(type: CoordinatorTransitionType = .push) -> Observable<Void> {
        let vc = MainViewController.instantiate(from: .main)
        vc.viewModel.toProfile
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
                return self.pushToProfile()
            }
            .subscribe()
            .disposed(by: disposeBag)

        vc.viewModel.toWeather
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
                return self.pushToWeather()
            }
            .subscribe()
            .disposed(by: disposeBag)

        navigationController.pushViewController(vc, animated: false)

        return Observable.never()
    }

    private func pushToProfile() -> Observable<Void> {
        let childCoordinator = ProfileCoordinator(navigationController: navigationController)
        return coordinate(to: childCoordinator)
    }

    private func pushToWeather() -> Observable<Void> {
        let childCoordinator = WeatherCoordinator(navigationController: navigationController)
        return coordinate(to: childCoordinator)
    }
}
