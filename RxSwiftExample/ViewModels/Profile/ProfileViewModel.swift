//
//  ProfileViewModel.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/10.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel {
    
    //Inputs
    let tapEdit = PublishSubject<Void>()

    //Outputs
    let name: BehaviorSubject<String>
    let birthday: BehaviorSubject<String>

    //Events
    let toEditProfile: Observable<ProfileProvider>

    init(_ provider: ProfileProvider) {
        name = provider.name
        birthday = provider.birthday

        toEditProfile = tapEdit
            .flatMap({ () -> Observable<ProfileProvider> in
                return .just(provider)
            })
    }
}
