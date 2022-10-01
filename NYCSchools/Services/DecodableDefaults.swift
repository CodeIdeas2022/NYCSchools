//
//  DecodableDefaults.swift
//  Services
//
//  Created by M1Pro on 9/30/22.
//  Reference: https://www.swiftbysundell.com/tips/default-decoding-values/

import Foundation

protocol DecodableDefaultSource {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}



enum DecodableDefault {}

extension DecodableDefault {
    @propertyWrapper
    struct Wrapper<Source: DecodableDefaultSource> {
        typealias Value = Source.Value
        var wrappedValue = Source.defaultValue
    }
}

extension DecodableDefault.Wrapper: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                   forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

extension DecodableDefault {
    typealias Source = DecodableDefaultSource
    typealias List = Decodable & ExpressibleByArrayLiteral
    typealias Map = Decodable & ExpressibleByDictionaryLiteral

    enum Sources {
        enum True: Source {
            static var defaultValue: Bool { true }
        }

        enum False: Source {
            static var defaultValue: Bool { false }
        }
        
        enum ZeroNumber: Source {
            static var defaultValue: Int { 0 }
        }

        enum EmptyString: Source {
            static var defaultValue: String { "" }
        }

        enum EmptyList<T: List>: Source {
            static var defaultValue: T { [] }
        }

        enum EmptyMap<T: Map>: Source {
            static var defaultValue: T { [:] }
        }
    }
}

extension DecodableDefault {
    typealias True = Wrapper<Sources.True>
    typealias False = Wrapper<Sources.False>
    typealias EmptyString = Wrapper<Sources.EmptyString>
    typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
    typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
    typealias ZeroNumber = Wrapper<Sources.ZeroNumber>
}

//@propertyWrapper
//struct DecodableString {
//    var wrappedValue = ""
//}
//
//extension DecodableString: Decodable {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        wrappedValue = try container.decode(String.self)
//    }
//}
//
//struct DecodableNumber {
//    var wrappedValue = 0
//}
//
//extension DecodableNumber: Decodable {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        wrappedValue = try container.decode(Int.self)
//    }
//}
//
//extension KeyedDecodingContainer {
//    func decode(_ type: DecodableString.Type,
//                forKey key: Key) throws -> DecodableString {
//        try decodeIfPresent(type, forKey: key) ?? .init()
//    }
//
//    func decode(_ type: DecodableNumber.Type,
//                forKey key: Key) throws -> DecodableNumber {
//        try decodeIfPresent(type, forKey: key) ?? .init()
//    }
//}
