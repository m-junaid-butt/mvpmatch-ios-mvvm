//
//  Bindable.swift
//  MVP Match
//
//  Created by Junaid Butt on 3/14/22.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
           observer?(value)
        }
    }

    var observer: ((T?)->())?
    
    func bind(observer: @escaping(T?)->()){
        self.observer = observer
    }
}
