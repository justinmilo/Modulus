import Combine
import SwiftUI


struct Parallel<A> {
  let run: (@escaping (A) -> Void) -> Void
}

//DispatchQueue.main.async(execute: <#T##() -> Void#>) -> Void
//UIView.animate(withDuration: <#T##TimeInterval#>, animations: <#T##() -> Void#>) -> Void
//URLSession.shared.dataTask(with: <#T##URL#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>) -> Void

//public typealias Effect<Action> = (@escaping (Action) -> Void) -> Void


public struct Effect<A> {
  public let run: (@escaping (A) -> Void) -> Void

  public init(run: @escaping (@escaping (A) -> Void) -> Void) {
    self.run = run
  }

  public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
    return Effect<B> { callback in self.run { a in callback(f(a)) } }
  }
}

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

//Button.init("Save", action: <#T##() -> Void#>)

public final class Store<Value, Action>: ObservableObject {
  private let reducer: Reducer<Value, Action>
  @Published public private(set) var value: Value
  private var cancellable: Cancellable?
  private var subscribers : [(Value)->Void] = []

  public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
    self.reducer = reducer
    self.value = initialValue
  }

  public func send(_ action: Action) {
    let effects = self.reducer(&self.value, action)
    subscribers.forEach{ $0(self.value)}
    effects.forEach { effect in
      effect.run(self.send)
    }
  }

  public func subscribe( callback: @escaping(Value)->Void) {
    subscribers.append(callback)
  }
  
  public func view<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(self.value),
      reducer: { localValue, localAction in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return []
    }
    )
    localStore.cancellable = self.$value.sink { [weak localStore] newValue in
      localStore?.value = toLocalValue(newValue)
    }
    return localStore
  }
}

public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducers.flatMap { $0(&value, action) }
    return effects
//    return { () -> Action? in
//      var finalAction: Action?
//      for effect in effects {
//        let action = effect()
//        if let action = action {
//          finalAction = action
//        }
//      }
//      return finalAction
//    }
  }
}


import CasePathse
public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: CasePath<GlobalAction, LocalAction>
) -> Reducer<GlobalValue, GlobalAction> {
  return { globalValue, globalAction in
   
   guard let localAction = action.extract(from: globalAction) else { return [] }
    let localEffects = reducer(&globalValue[keyPath: value], localAction)

    return localEffects.map { localEffect in
      Effect { callback in
        localEffect.run { localAction in
          callback(action.embed(localAction))
        }
      }
    }

//    return effect
  }
}



public func pullback<LocalValue, GlobalValue, Action>(
  _ reducer: @escaping Reducer<LocalValue, Action>,
  value: WritableKeyPath<GlobalValue, LocalValue>
) -> Reducer<GlobalValue, Action> {
  return { globalValue, action in
   
    let localEffects = reducer(&globalValue[keyPath: value], action)

    return localEffects.map { localEffect in
      Effect { callback in
        localEffect.run { action in
          callback(action)
        }
      }
    }

//    return effect
  }
}

public func pullback<Value, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<Value, LocalAction>,
  action: CasePath<GlobalAction, LocalAction>
) -> Reducer<Value, GlobalAction> {
  return { value, globalAction  in
   guard let localAction = action.extract(from: globalAction) else { return [] }

   let localEffects = reducer(&value, localAction)
   
    return localEffects.map { localEffect in
          Effect { callback in
            localEffect.run { localAction in
               callback(action.embed(localAction))
            }
          }
        }

//    return effect
  }
}



public func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [Effect { _ in
      print("Action: \(action)")
      print("Value:")
      dump(newValue)
      print("---")
    }] + effects
  }
}

public func logging<WholeValue,ValueablePart, Action>( _ path: WritableKeyPath<WholeValue, ValueablePart>,
  _ reducer: @escaping Reducer<WholeValue, Action>) -> Reducer<WholeValue, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [Effect { _ in
      print("Action: \(action)")
      print("Value:")
      dump(newValue[keyPath: path])
      print("---")
    }] + effects
  }
}

public func logging<WholeValue,ValueablePart, Action>( _ get: @escaping (WholeValue)-> ValueablePart,
  _ reducer: @escaping Reducer<WholeValue, Action>) -> Reducer<WholeValue, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [Effect { _ in
      print("Action: \(action)")
      print("Value:")
      dump(get(newValue))
      print("---")
    }] + effects
  }
}
