//
//  ProfileCoordinator.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/31.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit
import RxSwift

class ProfileCoordinator: Coordinator<Void> {

    override func start(type: CoordinatorTransitionType = .push) -> Observable<Void> {
        let vc = ProfileListViewController.instantiate(from: .profile)

        vc.viewModel.toAddProfile
            .flatMap { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.presentAddProfileViewController()
            }
            .filter {
                $0 }
            .map { _ in () }
            .observeOn(MainScheduler.instance)
            .bind(to: vc.viewModel.createProfile)
            .disposed(by: disposeBag)

        vc.viewModel.toProfile
            .subscribe(onNext: { [weak self] provider in self?.pushProfileViewController(provider) })
            .disposed(by: disposeBag)

        let didPop = navigationController.rx.willShow
            .filter { (viewController, _) -> Bool in viewController != vc }
            .filter { [weak self] (viewController, _) -> Bool in !(self?.navigationController.viewControllers.contains(vc) ?? false) }
            .flatMap { _ in Observable<Void>.just(()) }

        navigationController.pushViewController(vc, animated: true)

        return didPop
    }

    //Navigation
    private func pushProfileViewController(_ provider: ProfileProvider) {
        let vc = ProfileViewController.instantiate(from: .profile)
        vc.viewModel = ProfileViewModel(provider)
        vc.viewModel.toEditProfile
            .subscribe(onNext: { [ weak self] provider in self?.pushEditProfileViewController(provider) })
            .disposed(by: disposeBag)
        navigationController.pushViewController(vc, animated: true)
    }

    private func pushEditProfileViewController(_ provider: ProfileProvider) {
        let vc = EditProfileViewController.instantiate(from: .profile)
        vc.viewModel = EditProfileViewModel(provider)
        vc.viewModel.didSave
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.navigationController.popViewController(animated: true) })
            .disposed(by: disposeBag)
        navigationController.pushViewController(vc, animated: true)
    }

    private func presentAddProfileViewController() -> Observable<Bool> {
        let nc = UINavigationController()
        let childCoordinator = AddProfileCoordinator(navigationController: nc)
        navigationController.present(nc, animated: true)
        return coordinate(to: childCoordinator)
            .map { result in
                switch result {
                case .didCreate:
                    return true
                case .cancel:
                    return false
                }
        }
    }
}
