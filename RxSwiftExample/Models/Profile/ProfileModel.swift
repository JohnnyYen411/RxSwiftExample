//
//  ProfileModel.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/8.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import CoreData

struct Profile: Equatable {

    private var uuid: String = UUID().uuidString
    var name: String
    var birthday: String

    init() {
        self.name = ""
        self.birthday = ""
    }

    init(name: String, birthday: String, uuid: String = UUID().uuidString) {
        self.name = name
        self.birthday = birthday
        self.uuid = uuid
    }

    func getUuid() -> String {
        return self.uuid
    }

    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name && lhs.birthday == rhs.birthday
    }
}
