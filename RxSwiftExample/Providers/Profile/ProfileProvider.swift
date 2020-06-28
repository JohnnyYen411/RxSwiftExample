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
    let storageServices: StorageService

    init(_ storageServices: StorageService, _ profile: Profile = Profile()) {
        self.profile = profile
        self.name.onNext(profile.name)
        self.birthday.onNext(profile.birthday)
        self.storageServices = storageServices
    }

    deinit {
        name.onCompleted()
        birthday.onCompleted()
    }

    func getProfile() -> Profile {
        return profile
    }

    func create(_ profile: Profile) -> Observable<Profile> {
        return storageServices.insert(profile: profile)
    }

    func write(_ profile: (String, String, String)) -> Observable<Void> {
        let storServ = storageServices
        return storServ.write(uuid: profile.0, name: profile.1, birthday: profile.2)
            .flatMap { storServ.fetch(uuid: $0) }
            .map { [weak self] in
                    self?.profile = $0
                    self?.name.onNext($0.name)
                    self?.birthday.onNext($0.birthday)
                    return ()
            }
    }

    func isModified(_ inputs: Observable<(String, String)>) -> Observable<Bool> {
        return inputs.map { Profile(name: $0, birthday: $1) }
            .map { [weak self] in $0.name.count > 0 && $0.birthday.count > 0 && self?.profile != $0 }
    }

    func isValid(_ inputs: Observable<(String, String)>) -> Observable<Bool> {
        return inputs.map { $0.count > 0 && $1.count > 0 }
    }
}

extension Array where Element == ProfileProvider {

    init(_ profiles: [Profile], _ storageServices: StorageService) {
        self = profiles.map{ ProfileProvider(storageServices, $0) }
    }
}
