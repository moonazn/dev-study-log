//
//  main.swift
//  CowPractice
//
//  Created by 송지연 on 7/4/26.
//

import Foundation

// MARK: - CoW practice

//final class Storage {
//    var values: [Int]
//
//    init(_ values: [Int]) {
//        self.values = values
//    }
//
//    func copy() -> Storage {
//        Storage(values)
//    }
//}
//
//struct CowArray {
//    private var storage: Storage
//
//    init(_ values: [Int]) {
//        self.storage = Storage(values)
//    }
//
//    var values: [Int] {
//        storage.values
//    }
//
//    mutating func append(_ value: Int) {
//        if !isKnownUniquelyReferenced(&storage) {
//            storage = storage.copy()
//        }
//        storage.values.append(value)
//    }
//}
//
//var a = CowArray([1, 2, 3])
//var b = a
//
//print("a:", a.values) // [1, 2, 3]
//print("b:", b.values) // [1, 2, 3]
//
//b.append(4)
//
//print("a:", a.values) // [1, 2, 3]
//print("b:", b.values) // [1, 2, 3, 4]



//struct FileResource: ~Copyable {
//    let path: String
//}
//
//let a = FileResource(path: "data.txt")
//let b = a


// MARK: - borrowing, consuming, consume practice

struct User: ~Copyable {
    let name: String
}

func printName(_ user: borrowing User) {
    print(user.name)
}

func destroy(_ user: consuming User) {
    print(user.name)
}

func test() {
    let user = User(name: "Rosie")

    printName(user)     // 잠시 빌림
    print(user.name)    // 계속 사용 가능

    destroy(user)       // 함수 destroy가 소유권을 가져감
    print(user.name)    // ❌ error: 이미 consume된 값이라 사용 불가
}

/// consume: 명시적 소유권 이동
func run() {
    let original = User(name: "moonazn")
    let moved = consume original

    print(original) // ❌ error: consume된 값이라 사용 불가
    print(moved)
}
