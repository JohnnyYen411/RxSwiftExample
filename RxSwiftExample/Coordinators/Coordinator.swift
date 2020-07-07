//
//  Coordinator.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/31.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit.UINavigationController
import RxSwift

enum CoordinationResult {
    case complete
}

class Coordinator<ResultType> {
    typealias CoordinationResult = ResultType

    let disposeBag = DisposeBag()

    let navigationController: UINavigationController
    private let identifier = UUID()
    private var childCoordinators = [UUID: Any]()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func store<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    func free<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }

    func start(type: CoordinatorTransitionType = .push) -> Observable<CoordinationResult>{
        fatalError("override this function")
    }

    func coordinate<T>(to coordinator: Coordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start()
            .share()
            .do(onNext: { [weak self] _ in self?.free(coordinator: coordinator) })
    }
}

enum CoordinatorTransitionType {
    case push
    case present
}
