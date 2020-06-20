//
//  ProfileProvider.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/3.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class ProfileProvider {

    private var profile: Profile

    //Outputs
    let name = BehaviorSubject(value: "")
    let birthday = BehaviorSubject(value: "")
    let storageServices: StorageServices

    init(_ storageServices: StorageServices, _ profile: Profile = Profile()) {
        self.profile = profile
        self.name.onNext(profile.name)
        self.birthday.onNext(profile.birthday)
        self.storageServices = storageServices
    }

//    init(_ name: String, _ birthday: String) {
//        let p = Profile(name: name, birthday: birthday)
//        profile = p
//        self.name.onNext(name)
//        self.birthday.onNext(birthday)
//    }

    deinit {
        name.onCompleted()
        birthday.onCompleted()
    }

    func getProfile() -> Profile {
        return profile
    }

    func create(_ profile: Observable<Profile>) -> Observable<Bool> {
        let storServ = storageServices
        return profile
            .flatMap { storServ.insert(profile: $0) }
            .map { _ in true }
    }

    func update(_ profile: Observable<(String, String, String)>) -> Observable<Bool> {
        let storServ = storageServices
        return profile
            .flatMap { storServ.update(uuid: $0, name: $1, birthday: $2) }
            .flatMap { storServ.fetch(uuid: $0) }
            .map { [weak self] in
                self?.profile = $0
                self?.name.onNext($0.name)
                self?.birthday.onNext($0.birthday)
            }
            .map { _ in true }
    }

    func isModified(_ inputs: Observable<(String, String)>) -> Observable<Bool> {
        return inputs.map { Profile(name: $0, birthday: $1) }
            .map { [weak self] in $0.name.count > 0 && $0.birthday.count > 0 && self?.profile != $0 }
    }

    func isValid(_ inputs: Observable<(String, String)>) -> Observable<Bool> {
        return inputs.map { $0.count > 0 && $1.count > 0 }
    }
}
