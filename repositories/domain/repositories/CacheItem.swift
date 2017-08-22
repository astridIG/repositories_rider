//
//  CacheItem.swift
//  repositories
//
//  Created by Astrid on 22/8/17.
//  Copyright © 2017 Astrid. All rights reserved.
//

import Foundation

class CacheItem<T> {

    var value: T
    var version: Int
    var timestamp: Double

    init(value: T,
         version: Int,
         timestamp:  Double) {
        self.value = value
        self.version = version
        self.timestamp = timestamp
    }
}
