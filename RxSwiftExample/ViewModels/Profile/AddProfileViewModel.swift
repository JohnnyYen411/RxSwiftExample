//
//  AddProfileViewModel.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/2.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

class AddProfileViewModel {

    private let provider: ProfileProvider

    //Inputs
    let name = PublishSubject<String>()
    let birthday = PublishSubject<String>()
    let saveTap = PublishSubject<Void>()

    //Outputs
    let isValid: Observable<Bool>
    let didCreateProfile: Observable<Void>

    init(_ storageServices: StorageServices) {
        provider = ProfileProvider(storageServices)
        let inputs = Observable.combineLatest(name, birthday)
            .share(replay: 1)

        isValid = provider.isValid(inputs)
            .observeOn(MainScheduler.instance)

        let createProfile = saveTap.withLatestFrom(inputs)
            .map { Profile(name: $0, birthday: $1) }

        didCreateProfile = provider.create(createProfile)
            .filter { $0 }
            .map { _ in () }
    }
}
