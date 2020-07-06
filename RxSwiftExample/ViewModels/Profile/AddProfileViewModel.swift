//
//  AddProfileViewModel.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/2.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

class AddProfileViewModel {

    private let provider: ProfileProvider

    //Inputs
    let name = PublishSubject<String>()
    let birthday = PublishSubject<String>()
    let saveTap = PublishSubject<Void>()

    //Outputs
    let isValid: Observable<Bool>
    let didCreateProfile: Observable<Profile>
    let showError: Observable<String>

    init(_ storageService: StorageService = StorageService()) {
        let pvd = ProfileProvider(storageService)
        provider = pvd
        let inputs = Observable.combineLatest(name, birthday)
            .share()

        isValid = provider.isValid(inputs)

        let createProfile = saveTap.withLatestFrom(inputs)
            .map { Profile(name: $0, birthday: $1) }
            .flatMap { pvd.create($0).materialize() }
            .share()

        didCreateProfile = createProfile.elements()
        
        showError = createProfile.errors()
            .map { $0.localizedDescription }

    }
}
