//
//  main.swift
//  OptionalMemoryTest
//
//  Created by 지연 on 7/3/26.
//

import Foundation

// MARK: - Optional Extra Inhabitant Optimization test

//print("Int 타입 메모리 사용량: \(MemoryLayout<Int>.size) bytes")
//print("Int? 타입 메모리 사용량: \(MemoryLayout<Int?>.size) bytes")
//
//print("--------------------------------")
//
//print("String 타입 메모리 사용량: \(MemoryLayout<String>.size) bytes")
//print("String? 타입 메모리 사용량: \(MemoryLayout<String?>.size) bytes")
//
//print("--------------------------------")
//
//print("Bool 타입 메모리 사용량: \(MemoryLayout<Bool>.size) bytes")
//print("Bool? 타입 메모리 사용량: \(MemoryLayout<Bool?>.size) bytes")
//
//class Person {
//    let name: String
//    init(name: String) {
//        self.name = name
//    }
//}
//
//let person = Person(name: "moonazn")
//
//let optionalPerson: Person? = person
//
//let nilPerson: Person? = nil
//
//print("--------------------------------")
//
//print("Person 타입 크기: \(MemoryLayout<Person>.size) bytes")
//print("Person? 타입 크기: \(MemoryLayout<Person?>.size) bytes")
//
//print("--------------------------------")
//
//print("person address: \(Unmanaged.passUnretained(person).toOpaque())")
//
//if let optionalPerson {
//    print("optionalPerson address: \(Unmanaged.passUnretained(optionalPerson).toOpaque())")
//}
//
//print("nilPerson: \(String(describing: nilPerson))")


// MARK: - Optioanl check test (강제 언래핑 시 어셈블리 수준 동작 방식 확인)

/// some
let value: Int? = 42
let x = value!

print(x)

/// none
let optionalValue: Int? = nil
let y = optionalValue!
