//
//  ProfileEntity+CoreDataProperties.swift
//  
//
//  Created by Johnny Yen on 2020/6/18.
//
//

import Foundation
import CoreData


extension ProfileEntity {

    @nonobjc public class func profileEntityFetchRequest() -> NSFetchRequest<ProfileEntity> {
        return NSFetchRequest<ProfileEntity>(entityName: "ProfileEntity")
    }

    @NSManaged public var uuid: String?
    @NSManaged public var name: String?
    @NSManaged public var birthday: String?

    var profile: Profile {
        set {
            self.uuid = newValue.getUuid()
            self.name = newValue.name
            self.birthday = newValue.birthday
        }

        get {
            return Profile(name: name ?? "", birthday: birthday ?? "", uuid: uuid ?? "")
        }
    }
}
