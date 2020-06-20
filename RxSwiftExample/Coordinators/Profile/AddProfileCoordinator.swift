//
//  AddProfileCoordinator.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/3.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

enum AddProfileCoordinationResult {
    case didCreate
    case cancel
}

class AddProfileCoordinator: Coordinator<AddProfileCoordinationResult> {

    override func start(type: CoordinatorTransitionType = .push) -> Observable<AddProfileCoordinationResult>{
        let vc = AddProfileViewController.instantiate(from: .profile)

        let didCreate = vc.viewModel.didCreateProfile
            .map { _ in
                AddProfileCoordinationResult.didCreate }

        guard let presentationController = navigationController.presentationController else { return Observable.empty() }

        let cancel = presentationController.rx.didDismiss
            .map { _ in AddProfileCoordinationResult.cancel }

        navigationController.pushViewController(vc, animated: false)

        return Observable.merge(didCreate, cancel).take(1)
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.navigationController.dismiss(animated: true) })
    }
}
