# Collection

## 목차
- [Collection](https://github.com/moonazn/dev-study-log/blob/main/Swift/Collection.md#collection-1)
- [Hash](https://github.com/moonazn/dev-study-log/blob/main/Swift/Collection.md#1-hash))
- [Hashable](https://github.com/moonazn/dev-study-log/blob/main/Swift/Collection.md#2-hashable)
- [Equatable](https://github.com/moonazn/dev-study-log/blob/main/Swift/Collection.md#3-equatable-프로토콜)
- [inout](https://github.com/moonazn/dev-study-log/blob/main/Swift/Collection.md#4-inout)
- [stride](https://github.com/moonazn/dev-study-log/blob/main/Swift/Collection.md#stride)
- [allSatisfy](https://github.com/moonazn/dev-study-log/blob/main/Swift/Collection.md#allsatisfy)

### 학습 키워드
- 2차원 배열
- 데이터 구조
- 해시맵

## Collection
Swift의 컬렉션 타입: 배열(array), 집합(set), 딕셔너리(dictionary)

- 저장할 수 있는 값의 타입과 키의 타입이 명확 (= 컬렉션에서 값을 조회할 때의 타입이 명확하다)
- Swift의 배열, 집합, 딕셔너리는 제네릭 컬렉션으로 구현됨.
- 컬렉션은 mutable (내부 아이템 추가, 삭제, 변경 가능)
  - 상수에 할당된 컬렉션은 불가변성을 가진다. (크기와 내용 변경 불가)
  - 변경이 필요하지 않은 컬렉션을 상수로 선언하면 쉽게 추론 가능 + Swift 컴파일러가 생성한 컬렉션의 성능 최적화 가능

### a) 배열
- 순서대로 같은 타입의 값 저장
- 중복값 허용
- Foundation의 NSArray 클래스와 연결됨.
- 후행 콤마 허용 (요소 추가, 삭제 시 Git diff가 깔끔해짐, 코드 수정 시 용이)

### b) 집합
- 순서 X
- 중복값 허용 X (Set에 저장하는 타입은 반드시 Hashable = hash value를 계산할 수 있는 방법이 있어야 함.)
- Foundation의 NSSet 클래스와 연결됨.
- 집합 연산 수행 가능: `a.intersection(b)`, `a.symmetricDifference(b)`, `a.union(b)`, `a.subtracting(b)`
  ![](Collection/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202026-06-21%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%202.06.01.png)<!-- {"width":555} -->

### c) 딕셔너리
- 순서 X
- 같은 타입의 키와 같은 타입의 값을 가짐.
- 고유한 키로 값을 식별
- Foundation의 NSDictionary 클래스와 연결됨.

## Dictionary.init(uniqueKeysWithValues:) 
### 딕셔너리
: 키와 값으로 이루어진 데이터를 담는 컨테이너

- 각 값은 **고유의 유일한 키**와 연결되어 있음. (키는 Hashable)
- 순서 X (array는 순서 O)
- 키로 값을 찾을 수 있음. (시간복잡도 O(1))

uniqueKeysWithValues: 배열을 딕셔너리로 변환 시에 사용하는 생성자
사용 예시
```swift
let students: [String] = ["Apple", "Banana", "Cat"]

var score: [String: Int] = Dictionary(uniqueKeysWithValues: students.map { ($0, $0.count) })	// score는 ["A": 5, "B": 6, "C": 3]이 된다.
```


#### +1: Hash
데이터를 관리, 유지하는 자료구조

- 데이터들을 해시 함수를 통해 key로 분류, 그 key에 따라 value를 저장하는 형태
- 같은 입력 -> 같은 해시값
- 동작 예시) key -> hash Function(key) = Hash Table에서의 index -> value
  - 해시 함수: 임의의 길이의 데이터를 고정된 길이의 해시값으로 변환하는 수학적 함수
    - 주어진 데이터에 대해 고유 & 예측 불가능한 해시값을 생성해야 함.
    - 서로 다른 입력이 동일한 해시값을 가지는 경우를 최소화해야 함. (해시 충돌 방지 필요)
- **효율적인 데이터 관리 목적**
  - 데이터베이스, 캐시 시스템, 검색 엔진, 컴파일러 등에서 데이터의 중복성을 줄이고 검색 속도를 높이기 위하여 해시가 사용됨.
    - 데이터 중복 검사 방법: 해시 테이블을 사용하여 각 요소를 해시값으로 변환 후 중복 항목 걸러낼 수 있음. (비교 자체를 없애는 것이 X, 비교 대상을 좁혀준다.)
      - 해시 사용 X -> 중복 검사를 위해 기존 데이터와 순차 비교해야 함.
      - 해시 테이블 사용 -> 해시값을 통해 저장 위치를 바로 찾을 수 있음 -> 평균 O(1)에 중복 여부를 알 수 있음. 해시 충돌 발생 시에만 실제 값 비교 수행하면 된다.
    - 암호화 알고리즘에서 데이터의 무결성을 검증하는 데에 사용됨.
      - 파일의 체크섬 / 디지털 서명 = 해시 값을 사용하여 데이터의 변경 여부 확인
        - 예) 파일 전송 중 해시를 사용하여 데이터 손상 여부 확인 가능
      - 데이터 무결성(Data Integrity): 데이터의 수명 주기 동안 정확성, 일관성, 유효성이 유지되는 것을 보장하는 특성
  - 해시 사용 시 빠르게 특정 데이터를 찾을 수 있는 이유? **해시 테이블**
- 서로 다른 입력이 같은 해시값을 가질 수 있음. (= 해시 충돌)
  - **해시 충돌 발생 이유**
    - 입력값 개수 = 사실상 무한, 해시값 개수 = 유한
- hashValue: Swift5 기준으로 hashValue 직접 설정 불가능(deprecated) -> `hash(into:)` 사용
  - get만 가능하기 때문에 따로 값 지정 불가
  - int형으로 유한한 범위 -> 해시 충돌 발생 가능

> ### 해시가 뭐예요?
> 임의의 데이터를 일정한 규칙(해시 함수)에 따라 고정된 값으로 변환한 결과이다.
> 이렇게 변환된 값 = 해시값
> 주로 빠른 탐색을 위해 사용됨.
> Dictionary나 Set은 키의 해시값을 이용하여 실제 값의 저장 위치를 빠르게 찾아 평균 O(1)의 성능 제공
> 그러나 해시 충돌이 발생할 수도 있기 때문에 실제 구현에서는 충돌 처리 로직도 함께 사용된다.

> ### 해시 vs 암호화: 둘은 다른가?
> 1) **해시**: 변환 후 원래 값으로 복원할 수 없음.
> 2) **암호화**: 암호화 키를 알면 다시 복호화 가능. (원래 값으로 복원 가능)

> ### 해시 충돌 해결
> > 해시 충돌: 서로 다른 데이터인데 같은 해시값이 나옴. -> 둘 다 같은 위치에 값을 저장하려고 하기 때문에 충돌 발생
> 1. **Chaining**: 같은 해시값이 나올 경우 연결 리스트 / 배열에 계속 추가
>    - 구현 단순, 충돌이 많아도 동작
>    - 해시 테이블의 크기를 변경하지 않아도 쉽게 확장 가능
>    - 충돌이 발생하더라도 데이터의 주소값은 바뀌지 X (Closed Addressing)
>    - 충돌 많아지면 O(n)
>    - 추가적인 메모리 공간 필요
> 2. **Open Addressing**: 충돌이 나면 다른 빈 칸 찾기
>    - 선형 탐사: 테이블 내에서 순차적으로 다음 빈 공간 탐색
>      - 모든 데이터가 동일한 배열에 저장되어 있음 -> 연결 리스트를 사용하는 체이닝보다 메모리 관리 이득
>      - 해시 테이블이 꽉 차면 더 이상 데이터 저장 불가
>      - 클러스터링 문제: 충돌이 많을 경우 인접한 공간이 점점 채워져 성능이 저하하는 현상 발생
>    - 이중 해싱: 충돌 발생 시 두 번째 해시 함수로부터 다음 빈 공간의 인덱스 계산 후 저장
>      - 충돌이 나면 일정 간격으로 다른 칸 탐색
>      - 선형 탐사의 클러스터링 문제 완화
>        - ==🟢선형 탐사는 충돌 발생 시 모든 키가 비슷한 위치에 몰리는 클러스터링 문제가 발생, 반면 이중 해싱은 **두 번째 해시 함수가 키마다 다른 이동 간격을 제공**하므로 충돌이 분산되어 클러스터링을 줄일 수 있음.==
>      - 두 개의 해시 함수를 사용하기 때문에 구현 복잡
>      - 해시 테이블의 크기가 **소수**로 설정되어야 효율적 (소수가 X -> 일부 칸만 반복해서 방문, 모든 버킷을 고르게 탐색하지 못함.)
> #### Swift Dictionary는 Open Addressing 사용

> ### 해시 테이블 resizing = O(n)
> 해시 테이블이 꽉 차면 해시 테이블의 크기를 늘려야 함.
> 이때 기존의 모든 데이터를 다시 해싱해서 재배치해야하기 때문에 O(n)이다.

> 해시를 사용할 때 ‘평균’ O(1)인 이유
> : 충돌 / 리사이징 과정이 발생할 수 있기 때문이다.

#### +2: Hashable
해시값을 생성하게 하는 Hash가 가능한 타입 ( = 객체를 해시값으로 변환할 수 있음을 의미 )

- 대부분의 표준 값 타입(Int, String, Bool, Character, UUID 등)은 Hashable을 채택
  - ==🟡왜지? 같은 문자열 `“apple”`이 존재할 수 있는거 아닌가?==
    - Hashable의 의미는 ‘고유한 값을 만든다’가 X
    - **Hashable = ‘같은 값이면 같은 해시를 만들 수 있다’ = ‘해시값을 만들 수 있다’**
  - 진짜? 예외가 있나?
    - 함수는 Hashable이 X -> 딕셔너리 키로 사용할 수 없음.
      - 함수가 같은 함수인지, 함수의 해시를 어떻게 계산할지 정의하기 애매
    - 클래스도 기본적으로 X
      - 직접 Hashable 채택 가능
      - NSObject 계열은 Hashable 동작을 제공하는 경우가 있음.
    - 연관값이 없는 열거형은 기본적으로 Equatable / Hashable함.
- 개발자가 직접 만든 타입은 Hashable하지 X
  - Hash 가능하게 하기 위해서 Hashable 프로토콜을 채택해야 함.
    - **Hash가 가능하다 = 그 값을 고정된 정수값(hash value)로 변환할 수 있다**
- Swift의 Hashable 규칙: **“두 객체가 ==이면 반드시 같은 해시값이어야 한다.”**

> ### Hashable이면 해시값이 유일한가?
> 아니다. Hashable은 해시값을 계산할 수 있다는 의미이기 때문에 서로 다른 값이 같은 해시값을 가질 수 있다. ( = 해시 충돌 )
> - 즉, “사과”가 Hashable인 이유는 고유해서가 X, 같은 문자열이면 같은 해시를 계산하는 규칙을 정의할 수 있기 때문이다.
> - 해시는 고유성을 보장하는 기술이라기 보다 빠른 탐색을 위한 기술이라고 알고 있음.

> ### NSObject 계열은 Hashable 동작을 제공?
> Swift의 클래스는 기본적으로 Hashable이 X.
> Objective-C의 최상위 클래스인 NSObject는 `isEqual(_:)`, `hash`를 가지고 있음.
> -> 클래스가 NSObject 상속 시 Swift가 Hashable, Equatable 브리징을 해준다.
> - NSObject의 `isEqual(_:)` 기본 구현은 “같은 인스턴스인가?”(메모리 주소가 같은가?)이다.
>   - override하여 재정의 가능

#### +3: Equatable 프로토콜
Hashable은 Equatable을 준수하고 있다.
**이유**: 해시값이 항상 고유하지 X, 해시 충돌이 일어날 수 있기 때문에 해시값만으로는 정확도가 떨어짐 -> 추가로 동일한지 확인하는 Equatable이 필요함.

Hashable하게 만들기 위해서는
1. ==함수
   - Equatable 프로토콜
   - hashValue가 같을 수 있기 때문에 이를 방지하기 위하여 사용
2. `hash(into:)`
   - Hashable 프로토콜
   - hashValue를 구하기 위하여 사용
   - `combine(value)`에 들어가는 value는 ==함수의 구현에서 비교되는 요소와 동일해야 함.

> #### combine(value)?
> `hash(into:)`에서 `hasher.combine()`은 객체의 각 프로퍼티를 해시 계산에 반영하기 위한 메서드.
> (Hasher가 내부적으로 이 값들을 종합하여 최종 해시값을 생성함.)
> **== 연산에서 비교하는 프로퍼티와 동일한 프로퍼티를 combine()에 사용해야 “같은 객체로 판단되는 값들이 동일한 해시값을 갖는다”는 Hashable 규칙을 만족할 수 있다.** (다른 프로퍼티는 모두 같은 값을 갖지만 하나의 프로퍼티만 다른 값을 가지는 두 객체는 다른 해시값을 가져야 함. 그러나 combine()에 같은 값을 가지는 프로퍼티 요소만 포함되는 경우 같은 해시값을 가지게 될 수 있으므로.)

> #### Hasher
> : Swift 내부에 있는 타입(struct)
> - 역할: 여러 값을 적절히 섞어서 최종 해시값을 생성
> - Swift가 제공하는 해시 생성 도구
> - 개발자가 직접 해시 알고리즘을 구현하지 않아도 일관되고 안전한 해시값을 만들 수 있도록 제공됨.
> - 예시
>   ```swift
>   struct User: Hashable {
>   	let id: Int
>   	let name: String
>   	// inout: 함수에 복사본이 아닌 원본을 넘겨서 함수 밖의 값을 바꿀 수 있도록 함.
>   	// inout으로 넘기는 이유: Hasher는 combine()이 호출될 때마다 자신의 상태를 바꾸면서 최종 해시값을 도출하기 때문
>   	func hash(into hasher: inout Hasher) {
>   		hasher.combine(id)
>   		hasher.combine(name)
>   	}
>   }
>   ```

#### +4: inout
- Value 타입의 값을 Reference 타입의 값처럼 참조로 전달하고 싶을 때 사용하는 파라미터
- 함수 호출 시 argument 앞에 &를 붙여야 함. `greet(name: &name)`

**inout은 참조 전달(pass-by-reference)인가?**
X.
Copy-in Copy-out이다.
함수 호출 시 값을 복사해 사용한 뒤 결과를 원래 변수에 반영한다.
그러나 실제 구현에서는 성능을 위해 참조처럼 최적화되기도 함.

실제 동작:
1. 함수 호출 시 인수의 값이 복사됨.
2. 함수 본문에서 복사본이 수정됨.
3. 함수 리턴 시 복사본의 값이 기존 변수에 할당됨.

> ### 메모리 관리 주의해야 함.
> Swift는 “수정 중인 메모리는 독접적으로 접근한다.”는 규칙을 강제함.
> ```swift
> var nickname: String = "moonazn"
> 
> func rename(_ name: inout String) {
> 	name = nickname		// ❌ Thread 1: Simultaneous accesses to 0x100008000, but modification requires exclusive access (nickname에 대한 쓰기, 읽기 접근이 동시에 수행되어 에러 발생)
> }
> rename(&nickname)
> 
> ---
> 
> var nickname: String = "moonazn"
> var myNickname: String = "moonazn"
> 
> func rename(_ name: inout String) {
> 	name = myNickname	// 복사본을 읽으므로 문제 X
> }
> rename(&nickname)
> myNickname = nickname
> ```


## stride

```swift
for i in stride(from: 0, to: 5, by: 1) {
    print(i) 	// 0, 1, 2, 3, 4 (to는 포함 X)
}

for i in stride(from: 0, through: 5, by: 1) {
    print(i) 	// 0, 1, 2, 3, 4, 5 (through는 포함 O)
}

for i in 0...5 {
    print(i) 	// 0, 1, 2, 3, 4, 5
}
```

## allSatisfy
정의: `func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool`

- Collection의 모든 원소가 특정 조건을 만족시키는지 알고 싶은 경우 사용
- 하나라도 조건을 만족하지 않으면 즉시 false를 반환하고 순회 종료
- 시간복잡도는 최악의 경우 O(n)

예시 1
```swift
let numbers = [2, 4, 5, 8]

let result = numbers.allSatisfy { $0 % 2 == 0 }

print(result)	// false
```

예시 2
```swift
let numbers: [Int] = []

numbers.allSatisfy { $0 > 0 }	// true
```
왜 true? **반례가 없기 때문에**
(수학에서.. “공집합의 모든 원소는 조건을 만족한다”)

