# Optional

## 목차
- Optional
- Ownership
- Optional - 메모리 관점 (Extra Inhabitant Optimization)
  - ABI
- Optional Binding
- Optional Chaining

## Optional
: `‘값이 없다’`를 넘어서, 도메인에서 `’아직 정해지지 않음’`, `’존재하지 않음’`, `’적용되지 않음’`과 같은 상태를 표현하는 타입

- 선언된 변수/상수에 값이 있을 수도/없을 수도 있는 상황에서 활용하기 용이
  - **실제로 값이 들어가지 않은 상황에서 앱의 crush를 막아 프로그램의 안전을 확보할 수 있다.**
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
> #### 정리) 어떤 타입이 사용하지 않는 비트 패턴(extra inhabitant)을 가지고 있다면 Swift는 그 비트 패턴을 Optional의 .none과 같은 enum case를 표현하는 데 활용하여 별도의 tag 저장 공간을 줄이는 최적화를 시행한다.
> > 모든 Optional이 최적화되는 것은 아니다. 어떤 차이가 생기는거지? -> ABI..

> ### ABI가 무엇일까: Application Binary Interface
> : **컴파일된 프로그램들이 서로 약속하는 규칙**
> - API: 소스 코드 수준의 약속
>   - `func add(_ a: Int, _ b: Int) -> Int`일 때 `add(1, 2)`만 알고 사용하면 됨.
> - ABI: 기계어(바이너리) 수준의 약속
>   - `Int를 몇 byte로 저장할지`, `Optional은 어떻게 저장할지` 등 컴파일러가 알아야 함.
>   - `MemoryLayout<Int?>.size`가 8인 것도 ABI가 Int?는 이렇게 저장하기로 정해놨기 때문
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

1. 61: x8이 가리키는 메모리 위치(Optional의 payload 자리)에 1 넣기
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

