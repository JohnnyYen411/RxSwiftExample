//
//  MainViewModel.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/8.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

class MainViewModel {
    
    //Events
    let toProfile = PublishSubject<Void>()
    let toWeather = PublishSubject<Void>()
}
