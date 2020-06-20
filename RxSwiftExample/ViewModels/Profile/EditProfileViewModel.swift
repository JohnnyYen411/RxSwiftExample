//
//  EditProfileViewModel.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/31.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

class EditProfileViewModel {
    
    //Inputs
    let saveTap = PublishSubject<Void>()
    let inputName = PublishSubject<String>()
    let inputBirthday = PublishSubject<String>()

    //Outputs
    let isModified: Observable<Bool>
    let name: BehaviorSubject<String>
    let birthday: BehaviorSubject<String>

    //Events
    let didSave: Observable<Void>

    init(_ provider: ProfileProvider) {

        name = provider.name
        birthday = provider.birthday

        let inputs = Observable.combineLatest(inputName, inputBirthday)
            .share(replay: 1)

        isModified = provider.isModified(inputs)

        let saveProfile = saveTap.withLatestFrom(inputs)
            .map { (provider.getProfile().getUuid(), $0, $1) }

        didSave = provider.update(saveProfile)
            .filter { $0 }
            .map { _ in () }
    }
}
