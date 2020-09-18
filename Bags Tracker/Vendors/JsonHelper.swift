//
//  JsonHelper.swift
//
//  Created by Mikhail Muravev on 11/01/2019.
//  Copyright © 2019 M-Technology. All rights reserved.
//

import Foundation

typealias JSON = Any
typealias JSONDictionary = Dictionary<String, JSON>
typealias JSONArray = Array<JSON>

precedencegroup DefaultPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator >>> : DefaultPrecedence

func >>> <A, B>(a: A?, f: (A) -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .none
    }
}

func JSONAsString(_ object: JSON?) -> String? {
    if let value = object as? String {
        return value
    } else if let value = object {
        return "\(value)"
    }
    return nil
}

func JSONAsInt(_ object: JSON?) -> Int? {
    if let value = object as? Int {
        return value
    } else if let value = object as? NSNumber {
        return value.intValue
    } else if let value = object as? NSString {
        return value.integerValue
    }
    
    return nil
}

func JSONAsUInt8(_ object: JSON?) -> UInt8? {
    if let value = object as? UInt8 {
        return value
    } else if let value = object as? NSNumber {
        return value.uint8Value
    } else if let value = object as? NSString {
        return UInt8(value.intValue)
    }
    
    return nil
}

func JSONAsUInt16(_ object: JSON?) -> UInt16? {
    if let value = object as? UInt16 {
        return value
    } else if let value = object as? NSNumber {
        return value.uint16Value
    } else if let value = object as? NSString {
        return UInt16(value.intValue)
    }
    
    return nil
}

func JSONAsNumber(_ object: JSON?) -> NSNumber? {
    if let value = object as? NSNumber {
        return value
    } else if let value = object as? NSString {
        return Int64(value.longLongValue) as NSNumber
    }
    return nil
}

func JSONAsBool(_ object: JSON?) -> Bool? {
    return object as? Bool
}

func JSONAsDate(_ object: JSON?) -> Date? {
    return object as? Date
}

func JSONAsDictionary(_ object: JSON?) -> JSONDictionary? {
    return object as? JSONDictionary
}

func JSONAsArray(_ object: JSON?) -> JSONArray? {
    return object as? JSONArray
}

func JSONObject(_ object: JSON?) -> JSONDictionary? {
    return object as? JSONDictionary
}
