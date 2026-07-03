//
//  main.swift
//  InoutTest
//
//  Created by 지연 on 6/19/26.
//

// inout의 메모리 접근 충돌(exclusive access) test

/// a) 메모리 접근 충돌 버전
//var nickname: String = "moonazn"
//
//func rename(_ name: inout String) {
//    name = nickname
//}
//rename(&nickname)

/// b) 올바른 접근 버전
var nickname: String = "moonazn"
var myNickname: String = "moonazn"

func rename(_ name: inout String) {
    name = myNickname
}
rename(&nickname)
myNickname = nickname
