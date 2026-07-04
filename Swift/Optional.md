# Optional

## 목차
- [Optional](https://github.com/moonazn/dev-study-log/blob/main/Swift/Optional.md#optional-1)
- [Ownership](https://github.com/moonazn/dev-study-log/blob/main/Swift/Optional.md#-swift6-ownership)
- [Optional - 메모리 관점 (Extra Inhabitant Optimization)](https://github.com/moonazn/dev-study-log/blob/main/Swift/Optional.md#옵셔널은-메모리를-얼마나-사용하지)
  - [ABI](https://github.com/moonazn/dev-study-log/blob/main/Swift/Optional.md#abi가-무엇일까-application-binary-interface)
- [Optional Unwrapping 내부 동작 확인](https://github.com/moonazn/dev-study-log/blob/main/Swift/Optional.md#optional-체크-방법-강제-언래핑은-위험하다)
- [Optional Binding](https://github.com/moonazn/dev-study-log/blob/main/Swift/Optional.md#1-optional-binding)
- [Optional Chaining](https://github.com/moonazn/dev-study-log/blob/main/Swift/Optional.md#2-optional-chaining)

## Optional
: `‘값이 없다’`를 넘어서, 도메인에서 `’아직 정해지지 않음’`, `’존재하지 않음’`, `’적용되지 않음’`과 같은 상태를 표현하는 타입

- 선언된 변수/상수에 값이 있을 수도/없을 수도 있는 상황에서 활용하기 용이
  - **실제로 값이 들어가지 않은 상황에서 앱의 비정상 종료를 막아 프로그램의 안전을 확보할 수 있다.**
- 옵셔널 바인딩과 옵셔널 체이닝을 통해 옵셔널 값을 안전하게 언래핑하고 기본 값에 접근할 수 있다.

### 옵셔널은 enum
```swift
enum Optional<Wrapped> {
  case none
  case some(Wrapped)
}
```
- `let a: Int? = 3` -> 실제로는 `let a = Optional.some(3)`
- `let b: Int? = nil` -> 실제로는 `let b = Optional.none`

공식 문서에는 다음과 같이 되어 있다. [Optional | Apple Developer Documentation](https://developer.apple.com/documentation/swift/optional)
```swift
@frozen
enum Optional<Wrapped>
where Wrapped : ~Copyable, Wrapped : ~Escapable
```
- `@frozen`: 앞으로 enum case가 추가되지 않는다는 의미이다. (즉 Optional은 none과 some 두개만 가진다는 것을 컴파일러가 알고 있음.)
- `Wrapped`: Optional은 제네릭으로 선언되어 있다. (`Optional<Int>`, `Optional<String>` 등 모두 가능)
- `Wrapped : ~Copyable`: Copyable일 필요 X, 즉 복사 가능한 타입 / 복사 불가능한 타입 모두 Optional 안에 넣을 수 있다.
  - = ownership 타입도 담을 수 있음.
- `Wrapped : ~Escapable`: Escapable이 아닌 타입도 Optional 안에 담을 수 있다.

---
### + Swift6 Ownership?
: 값의 **소유권**을 설명하는 모델

- **메모리 관리와 최적화**를 위해 도입된 개념으로 변수나 객체가 어디에서 생성 / 사용 / 해제되는지를 명확하게 정의하는 역할을 한다.
- Swift는 기본적으로 ARC를 사용하여 메모리를 관리하지만, 불필요한 복사와 성능 저하를 방지하기 위해 소유권 시스템을 도입하였다.
  - 참조 타입(class)에서 잘못된 접근(순환 참조 등) 발생 시 메모리 누수 우려
  - ==🟢값 타입(struct)에서 불필요한 복사 방지가 중요 -> 값 타입을 복사하지 않고 consume 사용 시 **메모리와 성능 최적화 가능**==
- 소유권이 사라진 변수를 잘못 사용 시 Swift가 컴파일 단계에서 잡아주기 때문에 안정성 향상

#### class는 참조 타입
class는 힙에 만들어진 인스턴스를 가리키는 **참조**가 변수에 저장된다.
이때 참조는 ARC(Automatic Reference Counting)로 관리되며 참조 카운트가 0이면 메모리에서 자동 해제.

```swift
class Person {
	var name: String
	init(name: String) { self.name = name }
}

let person1 = Person(name: "moonazn")
let person2 = person1
```
- `let person2 = person1`: 같은 인스턴스를 바라보는 참조 +1 (인스턴스 복사 X)
- `person2.name = "jiyeon"`: person1.name도 “jiyeon”

#### struct는 값 타입
struct 값을 다른 변수에 할당하면 **논리적으로 값이 복사**된다.

- “논리적 값 복사”?: Swift 컴파일러는 성능을 위해 실제 메모리 복사를 최적화할 수 있다.
- struct 안에 class 인스턴스가 들어 있으면 struct 값이 복사될 때 class의 인스턴스가 복사되지는 않지만 그에 대한 **참조가 복사**된다. ( = class 인스턴스 자체가 deep copy된 것이 X)
  - 값 타입이라고 해서 모든 내부 객체를 복제하지는 X, 겉으로 값처럼 동작하도록 함.
- struct 안에 참조 타입을 넣을 때는 **해당 참조가 공유되어도 되는지** 고려해야 한다.

> ### 클래스보다 구조체가 메모리 효율적이라고 말하는 이유는?
> 항상 클래스보다 구조체가 메모리를 덜 쓰는 것은 아니고, 상황에 따라 다르다.
> 그러나 작은 타입의 경우..
> - 구조체는 내부 프로퍼티 저장
> - 클래스는 실제 객체가 힙에 존재한다.
>   - 힙 할당 비용 ↑ (힙 할당은 스택보다 훨씬 비쌈)
>   - 힙 오브젝트 헤더가 붙음.
>   - ARC 참조 카운트 관리 필요
>   - 메타데이터 포인터 등 추가 오버헤드 존재
> -> 작은 객체 하나로 보면 구조체가 메모리 효율적
> #### ==🟡하지만 여러 곳에서 사용하는 경우 구조체는 복사하는 반면 클래스는 인스턴스 하나에 참조만 늘어나니까 더 메모리를 아낄 수 있지 않나?==
> - 구조체는 전체 복사 비용이 너무 커지므로 이때 적용되는 최적화가 **Copy-on-Write**
>   - 구조체의 장점 + 클래스의 메모리 공유 장점 모두 가져갈 수 있음.
> - Apple이 구조체를 권장하는 이유는 메모리보다 Value Semantics 측면에서 더 유리하기 때문이다.
>   - 여러 변수에서 사용 시 서로 **독립적으로 작용**하여 코드 안전성을 확보할 수 있다.

#### Copy-On-Write: 필요할 때 복사하여 성능 최적화
Swift 표준 라이브러리의 대표적인 값 타입(Array, Dictionary, Set, String)은 CoW 전략을 사용한다.

-> value semantics를 유지하면서 성능 측면에서 유리해진다.

> **value semantics**: 값을 다른 변수에 대입하거나 함수에 전달한 이후에도 **각 값이 서로 독립적으로 동작**하는 특성
> - 코드 안정성, 가독성, 유지보수성 유리 -> Swift 권장

> ### value semantics를 제공하는 것은 값 타입 아닌가?
> 맞음. **CoW는 값 타입에서 이미 제공하는 value semantics 특성을 유지하면서 불필요한 복사를 줄이기 위한 최적화 전략.**

- 작동 과정
```
생성
 ↓
Storage 생성
 ↓
복사
 ↓
Storage 공유 (RC 증가)
 ↓
읽기
 ↓
그대로 사용
 ↓
쓰기 시도
 ↓
RC 확인
 ↓
RC == 1 ?
 ├─ YES → 그대로 수정
 └─ NO → Storage 복사 후 수정
```

- 직접 CoW 구현해보기
```swift
final class Storage {
	var values: [Int]

	init(_ values: [Int]) {
		self.values = values
	}

	func copy() -> Storage {
		Storage(values)
	}
}

struct CowArray {
	private var storage: Storage
	
	init(_ values: [Int]) {
		self.storage = Storage(values)
	}

	var values: [Int] {
		storage.values
	}

	mutating func append(_ value: Int) {
		if !isKnownUniquelyReferenced(&storage) {
			storage = storage.copy()
		}
		storage.values.append(value)
	}
}

var a = CowArray([1, 2, 3])
var b = a

print("a:", a.values) // [1, 2, 3]
print("b:", b.values) // [1, 2, 3]

b.append(4)

print("a:", a.values) // [1, 2, 3]
print("b:", b.values) // [1, 2, 3, 4]
```
-> 내부 저장소는 필요한 순간에만 복사👍🏻

#### Copyable: 복사 가능한 타입
Swift에서 대부분의 타입(struct, enum, class 등)은 `Copyable`이다.

복사하면 안되는 값은? 예를 들어 파일 디스크립터, 소켓 핸들, 일회성 토큰, 락 등..
하나의 소유자만 가져야 안전한 값들을 기존에는 class로 표현했음.
**그러나** 힙 할당 & 참조 카운팅 비용이 들고, 여러 참조가 같은 리소스를 공유할 수도 있다.

#### ~Copyable: 복사 불가능한 타입
`~Copyable` 타입은 **하나의 소유권**을 가진다.

```swift
struct FileResource: ~Copyable {
    let path: String
}

let a = FileResource(path: "data.txt")
let b = a // ❌ error: Cannot consume noncopyable stored property 'a' that is global
```

> #### isKnownUniquelyReferenced
> : 주어진 오브젝트를 가리키는 강한 참조가 하나뿐이라고 판단 시 true 반환
> - 복수의 쓰레드에서 해당 오브젝트에 접근하거나, 약한 참조만을 가지는 상황에서는 true 반환 가능
>   - 약한 참조는 strong reference count에 포함되지 않기 때문

#### borrowing, consuming
- `borrowing`: 값을 빌려서 잠시 사용
  - 소유권을 가져오지 X
  - 값을 소비하지 X
  - 읽기 용도로 사용
  - 호출이 끝나면 원래 소유자가 계속 값 사용 가능
- `consuming`: 함수가 값을 소비, 즉 소유권을 가져온다.
  - 호출자의 값 소유권을 함수 쪽으로 넘김.
  - 한 번만 사용되어야 하는 값을 표현할 때 사용

```swift
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
```

> #### consume 당한 변수는 사라질까?
> consume으로 소유권이 이동한 후 원래 소유권을 가지던 변수는 사라지지 않고 비어 있는 uninitialized 상태가 된다.
> - uninitialized: 변수가 초기화되지 않은 상태
> - deinitialized: 객체가 해제(deinit)되어 메모리가 반환된 상태
> -> 따라서 새로운 값을 할당하면 변수를 재초기화하여 사용할 수 있다.

> ==🟢값 타입(struct)에서 불필요한 복사 방지가 중요 -> 값 타입을 복사하지 않고 consume 사용 시 **메모리와 성능 최적화 가능**==
> #### 왜 값 타입을 복사하지 않고 consume을 사용하면 메모리와 성능 최적화가 될까? 똑같이 기존 변수는 사용하지 못하게 되는 것 아닌가?
> 기존 변수는 동일하게 비게 된다. 그러나 원본과 새 값이 모두 살아있게 되는 복사와 달리 `consume` 사용 시 **원본을 살려둘 필요가 없다는 사실을 컴파일러가 알 수 있게 되므로** 이 부분에서 성능 최적화가 가능해진다.

---
> ### 옵셔널은 메모리를 얼마나 사용하지?
> enum은 어떤 case인지 분류하기 위한 ‘tag’를 위한 추가 메모리가 필요하다.
> (연관값이 있는 enum의 경우 추가 ‘payload’를 위한 메모리도 필요)
> ==🟣옵셔널도 enum이므로 일반 타입보다 메모리가 더 들어갈 것이라고 생각했다. (메모리가 낭비되지 않을까?)==
> ```swift
> print("Int 타입 메모리 사용량: \(MemoryLayout<Int>.size) bytes")
> print("Int? 타입 메모리 사용량: \(MemoryLayout<Int?>.size) bytes")
> 
> /// Int 타입 메모리 사용량: 8 bytes
> /// Int? 타입 메모리 사용량: 9 bytes
> ```
> 1byte가 더 사용된다. (1byte는 some인지 none인지 저장하기 위함.)
> #### Extra Inhabitant Optimization
> swift는 굳이 tag를 따로 저장하지 않아도 되는 경우를 찾아낸다.
> - **참조 타입에서는 옵셔널이어도 크기가 같다.**
>   - -> 이유: **포인터 주소 `0x0`을 nil로 사용하기 때문** (실제 객체는 주소 0에 할당되지 않기 때문에 구분 가능)
> ```
> Person 타입 크기: 8 bytes
> Person? 타입 크기: 8 bytes
> --------------------------------
> person address: 0x000000010082d980
> optionalPerson address: 0x000000010082d980
> nilPerson: nil	// 즉 0x0000000000000000
> ```
> - **Bool 타입의 경우에도 크기가 같다.**
>   - -> 이유: Bool은 0과 1 두 개만 쓰지만 1byte로 256가지를 표현할 수 있기 때문에 남는 비트 패턴을 nil로 활용
> 이때 payload 안에 사용하지 않는 값 = **Extra Inhabitant** (사용할 수 없는 비트 패턴)
> [테스트 코드](https://github.com/moonazn/dev-study-log/blob/main/Swift/Examples/OptionalUnwrapTest.swift)
> #### 정리) 어떤 타입이 사용하지 않는 비트 패턴(extra inhabitant)을 가지고 있다면 Swift는 그 비트 패턴을 Optional의 .none과 같은 enum case를 표현하는 데 활용하여 별도의 tag 저장 공간을 줄이는 최적화를 시행한다.
> > 모든 Optional이 최적화되는 것은 아니다. 어떤 차이가 생기는거지? -> ABI..

> ### ABI가 무엇일까: Application Binary Interface
> : **컴파일된 프로그램들이 서로 약속하는 규칙**
> - API: 소스 코드 수준의 약속
>   - `func add(_ a: Int, _ b: Int) -> Int`일 때 `add(1, 2)`만 알고 사용하면 됨.
> - ABI: 기계어(바이너리) 수준의 약속
>   - `Int를 몇 byte로 저장할지`, `Optional은 어떻게 저장할지` 등 컴파일러가 알아야 함.
>   - `MemoryLayout<T>.size`가 타입마다 다르게 나오는 것도 ABI와 컴파일러의 메모리 표현 방식에 영향을 받기 때문.
> > ### 정리
> > - ABI = 타입의 메모리 표현과 호출 규약 등을 정의하는 규칙
> > - Extra Inhabitant Optimization은 Swift 컴파일러와 ABI가 함께 보장하는 메모리 표현 방식의 일부

### Optional 체크 방법: 강제 언래핑은 위험하다
```asm6502
// 의사 코드
cmp optional_tag, SOME
jne trap

mov x0, payload
```
1. 옵셔널인지 체크 (some인지 none인지) (cmp: compare)
2. 옵셔널 값 태그가 some인 경우 값을 복사해서 레지스터(위에서는 x0)에 담기 (즉 코드에서 값을 계속 사용할 수 있도록 함) (mov: move, 즉 값 복사)
3. 옵셔널 값 태그가 none인 경우 trap (jne: Jump if Not Equal)

#### trap?
: 실행하면 안 되는 상황을 운영체제에 알리는 명령어
(brk, ud2 등)
해당 명령 발생 시 프로세스 종료 후 Crash Report가 생성됨.
(`Fatal error:
Unexpectedly found nil while unwrapping an Optional value` 에러 발생)

#### 👓 실제로 확인해보기
실행한 소스 코드
```swift
/// some
let value: Int? = 42
let x = value!

print(x)

/// none
let optionalValue: Int? = nil
let y = optionalValue!
```

SIL 확인 (`swiftc -emit-sil`로 컴파일하여 확인)

<img width="941" height="323" alt="스크린샷 2026-07-03 오후 8 42 32" src="https://github.com/user-attachments/assets/77093056-a98f-4f55-9f41-1cb64a873632" />

- 95: “`.some`이면 값을 꺼내는 bb4 블록으로 가고, `.none`이면 런타임 trap을 발생시키는 bb3 블록으로 가라”
- 99: `cond_fail`은 Optional이 `.none`인 경우 런타임 trap을 발생시킨다.
- 100: `unreachable`은 trap 이후 정상적인 실행 흐름이 존재하지 않음을 의미한다.

> ### SIL?
> : **Swift Intermediate Language**
> [ Swift가 기계어로 가기 위한 과정 ]
> 1. Swift 코드
> 2. SIL
> 3. LLVM IR
> 4. Assembly
> 5. Machine Code
> `swiftc -emit-sil`으로 Swift 코드를 컴파일하며 최종 실행 파일을 만들지 않고 SIL 단계의 결과를 출력하여 확인하였다.

Assembly 확인

<img width="280" height="97" alt="스크린샷 2026-07-03 오후 9 16 07" src="https://github.com/user-attachments/assets/b2f59a99-b374-4cc7-9c5c-f531f07993bb" />

1. 61: x8이 가리키는 메모리 위치(Optional의 payload 자리)에 0 넣기
   - xzr: ARM64에서 항상 0인 레지스터
2. 62: x8 주소에서 8바이트 뒤 위치(Optional의 tag 자리)에 w21 값(= 1) 저장
   - 여기서 1은 nil 상태 의미
3. 65: 정상 실행을 멈추고 크래시 발생

> - 여기서의 코드들은 전부 해당 실험 환경에서 이렇게 표현되는 것이지 모든 상황에서 해당 코드들이 나오는 것이 X.
> - SIL과 Assembly 분석은 AI를 활용하여 학습


### 1) Optional Binding
옵셔널에 nil이 아닌 값이 포함된 경우에만 옵셔널 값을 안전하게 풀고 옵셔널이 아닌 변수/상수에 할당할 수 있다.

### 2) Optional Chaining
옵셔널에 nil이 아닌 값이 포함된 경우에만 옵셔널 값의 속성에 액세스하거나 메서드를 호출할 수 있다.

