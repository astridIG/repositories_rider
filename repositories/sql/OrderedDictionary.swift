// Copyright 2014 Brandon McQuilkin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  OrderedDictionary.swift
//  M13OrderedDictionary
//
//  Created by Brandon McQuilkin on 7/26/14.
//  Copyright (c) 2014 Brandon McQuilkin. All rights reserved.
//

import Foundation

struct OrderedDictionary<Key: Hashable, Value: Any>: Sequence, CustomStringConvertible {

    var keyStorage: Array<Key> = []
    var pairStorage: Dictionary<Key, Value> = [:]

    //MARK: Initalization

    /**Constructs an empty ordered dictionary.*/
    public init() {
    }

    /**Constructs an ordered dictionary with the keys and values in a dictionary.*/
    public init(dictionary: Dictionary<Key, Value>) {
        for aKey in dictionary.keys {
            keyStorage.append(aKey)
        }
        pairStorage = dictionary
    }

    /**Constructs an ordered dictionary with the keys and values from another ordered dictionary.*/
    public init(orderedDictionary: OrderedDictionary<Key, Value>) {
        keyStorage = orderedDictionary.keyStorage
        pairStorage = orderedDictionary.pairStorage
    }

    //MARK: Subscripts

    /**Gets or sets existing entries in an ordered dictionary by key using square bracket subscripting. If a key exists this will overrite the object for said key, not changing the order of keys. If the key does not exist, it will be appended at the end of the ordered dictionary.*/
    public subscript(key: Key) -> Value? {
        get {
            return pairStorage[key]
        }
        mutating set(newValue) {
            if let _ = pairStorage[key] {
                pairStorage[key] = newValue
            } else {
                keyStorage.append(key)
                pairStorage[key] = newValue
            }
        }
    }

    /**Gets or sets existing entries in an ordered dictionary by index using square bracket subscripting. If the key exists, its entry will be deleted, before the new entry is inserted; also, the insertion compensates for the deleted key, so the entry will end up between the same to entries regardless if a key is deleted or not.*/
    public subscript(index: Int) -> (Key, Value) {
        get {
            let key: Key = keyStorage[index]
            let value: Value = pairStorage[key]!
            return (key, value)
        }
        set(newValue) {
            let (key, value): (Key, Value) = newValue
            if let _ = pairStorage[key] {
                var idx: Int = 0
                if let keyIndex = keyStorage.index(of: key) {
                    if index > keyIndex {
                        //Compensate for the deleted entry
                        idx = index - 1
                    } else {
                        idx = index
                    }

                    //Remove the old entry
                    keyStorage.remove(at: keyIndex)
                    //Insert the new one
                    pairStorage[key] = value
                    keyStorage.insert(key, at: idx)
                }
            } else {
                //No previous value
                keyStorage.insert(key, at: index)
                pairStorage[key] = value
            }
        }
    }

    /**Gets or a subrange of existing keys in an ordered dictionary using square bracket subscripting with an integer range.*/
    public subscript(keyRange keyRange: Range<Int>) -> ArraySlice<Key> {
        get {
            return keyStorage[keyRange]
        }
    }

    /**Gets or a subrange of existing values in an ordered dictionary using square bracket subscripting with an integer range.*/
    public subscript(valueRange valueRange: Range<Int>) -> ArraySlice<Value> {
        get {
            return self.values[valueRange]
        }
    }

    //MARK: Adding

    /*Adds a new entry as the last element in an existing ordered dictionary.*/
    public mutating func append(newElement: (Key, Value)) {
        let (key, value) = newElement
        pairStorage[key] = value
        keyStorage.append(key)
    }

    /*Inserts an entry into the collection at a given index. If the key exists, its entry will be deleted, before the new entry is inserted; also, the insertion compensates for the deleted key, so the entry will end up between the same to entries regardless if a key is deleted or not.*/
    public mutating func insert(newElement: (Key, Value), atIndex: Int) {
        self[atIndex] = newElement
    }

    //MARK: Updating

    /**Inserts at the end or updates a value for a given key and returns the previous value for that key if one existed, or nil if a previous value did not exist.*/
    public mutating func updateValue(value: Value, forKey: Key) -> Value? {
        let test: Value? = pairStorage.updateValue(value, forKey: forKey)
        if let _ = test {
            //The key already exists, no need to add
        } else {
            keyStorage.append(forKey)
        }
        return test
    }

    //MARK: Removing

    /**Removes the key-value pair for the specified key and returns its value, or nil if a value for that key did not previously exist.*/
    public mutating func removeEntryForKey(key: Key) -> Value? {
        if let index = keyStorage.index(of: key) {
            keyStorage.remove(at: index)
        }
        return pairStorage.removeValue(forKey: key)
    }

    /**Removes all the elements from the collection and clears the underlying storage buffer.*/
    public mutating func removeAllEntries() {
        keyStorage.removeAll(keepingCapacity: false)
        pairStorage.removeAll(keepingCapacity: false)
    }

    /**Removes the entry at the given index and returns it.*/
    public mutating func removeEntryAtIndex(index: Int) -> (Key, Value) {
        let key: Key = keyStorage[index]
        let value: Value = pairStorage.removeValue(forKey: key)!
        keyStorage.remove(at: index)
        return (key, value)
    }

    /**Removes the last entry from the collection and returns it.*/
    public mutating func removeLastEntry() -> (Key, Value) {
        let key: Key = keyStorage[keyStorage.endIndex]
        let value: Value = pairStorage.removeValue(forKey: key)!
        keyStorage.removeLast()
        return (key, value)
    }

    //MARK: Properties

    /**An integer value that represents the number of elements in the ordered dictionary (read-only).*/
    public var count: Int {
        get {
            return keyStorage.count
        }
    }

    /**A Boolean value that determines whether the ordered dictionary is empty (read-only).*/
    public var isEmpty: Bool {
        get {
            return keyStorage.isEmpty
        }
    }

    //MARK: Enumeration

    /*Returns an ordered iterable collection of all of an ordered dictionaryâ€™s keys.*/
    public var keys: Array<Key> {
        get {
            return keyStorage
        }
    }

    /*Returns an ordered iterable collection of all of an ordered dictionaryâ€™s values.*/
    public var values: Array<Value> {
        get {
            var tempArray: Array<Value> = []
            for key: Key in keyStorage {
                tempArray.append(pairStorage[key]!)
            }
            return tempArray
        }
    }

    /*Returns an ordered iterable collection of all of an ordered dictionaryâ€™s entries.*/
    public var entries: Array<(Key, Value)> {
        get {
            var tempArray: Array<(Key, Value)> = []
            for key: Key in keyStorage {
                let temp = (key, pairStorage[key]!)
                tempArray.append(temp)
            }
            return tempArray
        }
    }

    //MARK: Sorting

    /**Sorts the receiver in place using a given closure to determine the order of a provided pair of elements.*/
    public mutating func sort(isOrderedBefore sortFunction: ((Key, Value), (Key, Value)) -> Bool) {
        var tempArray = Array(pairStorage)
        tempArray.sort(by: sortFunction)
        keyStorage = tempArray.map({
            let (key, _) = $0
            return key
        })
    }

    /**Sorts the receiver in place using a given closure to determine the order of a provided pair of elements by their keys.*/
    public mutating func sortByKeys(isOrderedBefore sortFunction: (Key, Key) -> Bool) {
        keyStorage.sort(by: sortFunction)
    }

    /**Sorts the receiver in place using a given closure to determine the order of a provided pair of elements by their values.*/
    public mutating func sortByValues(isOrderedBefore sortFunction: (Value, Value) -> Bool) {
        var tempArray = Array(pairStorage)
        tempArray.sort(by: {
            let (_, aValue) = $0
            let (_, bValue) = $1
            return sortFunction(aValue, bValue)
        })
        keyStorage = tempArray.map({
            let (key, _) = $0
            return key
        })
    }

    /**Returns an ordered dictionary containing elements from the receiver sorted using a given closure.*/
    public func sorted(isOrderedBefore: ((Key, Value), (Key, Value)) -> Bool) -> OrderedDictionary<Key, Value> {
        var temp: OrderedDictionary = OrderedDictionary(orderedDictionary: self)
        temp.sort(isOrderedBefore: isOrderedBefore)
        return temp
    }

    /**Returns an ordered dictionary containing elements from the receiver sorted using a given closure by their keys.*/
    public func sortedByKeys(isOrderedBefore: (Key, Key) -> Bool) -> OrderedDictionary<Key, Value> {
        var temp: OrderedDictionary = OrderedDictionary(orderedDictionary: self)
        temp.sortByKeys(isOrderedBefore: isOrderedBefore)
        return temp
    }

    /**Returns an ordered dictionary containing elements from the receiver sorted using a given closure by their values.*/
    public func sortedByValues(isOrderedBefore: (Value, Value) -> Bool) -> OrderedDictionary<Key, Value> {
        var temp: OrderedDictionary = OrderedDictionary(orderedDictionary: self)
        temp.sortByValues(isOrderedBefore: isOrderedBefore)
        return temp
    }

    /**Returns an ordered dictionary containing the elements of the receiver in reverse order by index.*/
    public func reverse() -> OrderedDictionary<Key, Value> {
        var temp = OrderedDictionary(orderedDictionary: self)
        temp.keyStorage = Array(temp.keyStorage.reversed())
        return temp
    }

    /**Returns an ordered dictionary containing the elements of the receiver for which a provided closure indicates a match.*/
    public func filter(includeElement filterFunction: ((Key, Value)) -> Bool) -> OrderedDictionary<Key, Value> {
        let tempArray = self.entries.filter(filterFunction)
        var temp = OrderedDictionary()
        for entry in tempArray {
            temp.append(newElement: entry)
        }
        return temp
    }

    /**Returns an ordered dictionary of elements built from the results of applying a provided transforming closure for each element.*/
    public func map<NewKey, NewValue>(transform aTransform: (Key, Value) -> (NewKey, NewValue)) -> OrderedDictionary<NewKey, NewValue> {
        let tempArray = Array(pairStorage)
        let newArray = tempArray.map(aTransform)
        var temp: OrderedDictionary<NewKey, NewValue> = OrderedDictionary<NewKey, NewValue>()
        for entry in newArray {
            temp.append(newElement: entry)
        }
        return temp
    }

    /**Returns an array of elements built from the results of applying a provided transforming closure for each element.*/
    public func mapToArray<T>(transform aTransform: (Key, Value) -> T) -> Array<T> {
        let tempArray = Array(pairStorage)
        return tempArray.map(aTransform)
    }

    /**Returns a single value representing the result of applying a provided reduction closure for each element.*/
    public func reduce<NewKey, NewValue>(initial value: (NewKey, NewValue), combine combo: ((NewKey, NewValue), (Key, Value)) -> (NewKey, NewValue)) -> (NewKey, NewValue) {
        let tempArray = Array(pairStorage)
        return tempArray.reduce(value, combo)
    }

    //MARK: Printable
    public var description: String {
        get {
            var temp: String = "OrderedDictionary {\n"
            let entries = self.entries
            let int = 0
            for entry in entries {
                let (key, value) = entry
                temp += "    [\(int)] {\(key): \(value)}\n"
            }
            temp += "}"
            return temp
        }
    }

    //MARK: Sequence
    public func makeIterator() -> IndexingIterator<[(Key, Value)]> {
        return self.entries.makeIterator()
    }

}

//MARK: Operators

/**Determines the equality of two ordered dictionaries. Evaluates to true if the two ordered dictionaries contain exactly the same keys and values in the same order.*/
func ==<Key, Value:Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs.keyStorage == rhs.keyStorage && lhs.pairStorage == rhs.pairStorage
}

/**Determines the similarity of two ordered dictionaries. Evaluates to true if the two ordered dictionaries contain exactly the same keys and values but not necessarly in the same order.*/
func ~=<Key, Value:Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs.pairStorage == rhs.pairStorage
}

/**Determines the inequality of two ordered dictionaries. Evaluates to true if the two ordered dictionaries do not contain exactly the same keys and values in the same order*/
func !=<Key, Value:Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs.keyStorage != rhs.keyStorage || lhs.pairStorage != rhs.pairStorage
}
