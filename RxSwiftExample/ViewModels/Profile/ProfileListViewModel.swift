//
//  ProfileListViewModel.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/10.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

class ProfileListViewModel {
    private let provider: ProfileListProvider

    //Inputs
    let clearTap = PublishSubject<Void>()
    let createProfile = PublishSubject<Void>()

    //Outputs
    let profileList: Observable<[ProfileProvider]>
    let hasItems: Observable<Bool>
    let showError: Observable<String>

    //Events
    let toAddProfile = PublishSubject<Void>()
    let toProfile = PublishSubject<ProfileProvider>()
    let didUpdateList: Observable<Void>
    let didClear: Observable<Void>

    init(_ storageService: StorageService = StorageService()) {
        let pvd = ProfileListProvider(storageService)
        provider = pvd
        profileList = provider.providers

        hasItems = profileList
            .map { $0.count > 0 }

        let fetchResult = Observable.merge(.just(()), createProfile)
            .flatMap { pvd.update().materialize() }
            .share()

        let clearResult = clearTap
            .flatMap { pvd.clearAll().materialize() }
            .share()

        didUpdateList = fetchResult.elements()

        didClear = clearResult.elements()

        showError = Observable.merge(fetchResult.errors(), clearResult.errors())
            .map { $0.localizedDescription }
    }
}
