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

    //Events
    let toAddProfile = PublishSubject<Void>()
    let toProfile = PublishSubject<ProfileProvider>()
    let didUpdateList: Observable<Void>
    let didClear: Observable<Void>

    init(_ storageServices: StorageServices) {
        provider = ProfileListProvider(storageServices)
        profileList = provider.providers
            .observeOn(MainScheduler.instance)

        hasItems = profileList
            .observeOn(MainScheduler.instance)
            .map {
                $0.count > 0 }

        let doFetch = Observable.merge(Observable.just(()), createProfile)

        didUpdateList = provider.update(doFetch)
            .observeOn(MainScheduler.instance)

        didClear = provider.clearAll(clearTap)
            .observeOn(MainScheduler.instance)
    }
}
