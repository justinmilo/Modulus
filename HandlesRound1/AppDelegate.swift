//
//  AppDelegate.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

precedencegroup Semigroup { associativity: left }
infix operator <>: Semigroup

protocol Semigroup {
  static func <>(lhs: Self, rhs: Self) -> Self
}

protocol Monoid: Semigroup {
  static var e: Self { get }
}

extension Array: Monoid {
  static var e: Array { return  [] }
  static func <>(lhs: Array, rhs: Array) -> Array {
    return lhs + rhs
  }
}


public func curry<A, B, C>(_ f : @escaping (A, B) -> C) -> (A) -> (B) -> C {
  
  return { (a : A) -> (B) -> C in
    { (b : B) -> C in
      
      f(a, b)
    }
  }
  
}

public func uncurry<A, B, C>(_ f : @escaping (A) -> (B) -> C) -> (A, B) -> C {
  
  return { (a : A, b: B) -> C in
     return f(a)(b)
  }
  
}



struct GraphEditingView {
  let build: (CGSize) -> (GraphPositions, [Edge])
  let size : (ScaffGraph) -> CGSize
  let composite : (ScaffGraph) -> (CGPoint) -> [Geometry]
  let origin : (ScaffGraph, CGRect, CGFloat) -> CGPoint
}

let graphToTextures :  (ScaffGraph) -> (CGPoint) -> [Geometry] = { $0.planEdgesNoZeros } >>> curry(planEdgeToGeometry)
let graphToNonuniform : (ScaffGraph) -> (CGPoint) -> NonuniformModel2D = { $0.grid } >>> planGrids
let nonuniformToDimensions : (NonuniformModel2D) -> [Geometry] = (nonuniformToPoints, 40) >>-> pointCollectionToDimLabel
// (A -> B, C ) (B, C) -> D
let graphToDimensions = graphToNonuniform >>> { f in return {p in f(p) |> nonuniformToDimensions }  }
let finalDimComp : (ScaffGraph) -> (CGPoint) -> [Geometry] = {
  g in
  return {
    p in
    return (g |> graphToTextures)(p) + (g |> graphToDimensions)(p)
  }}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
      self.window = UIWindow(frame: UIScreen.main.bounds)

      self.window?.makeKeyAndVisible()
      
      
      
      let postis = CGSize3(width: 100, depth: 100, elev: 350) |> createGrid
      let graph = ScaffGraph(grid: postis.0, edges: postis.1)
      
      let sizePlan : (CGSize) -> CGSize3 = { CGSize3(width: $0.width, depth: $0.height, elev: graph.bounds.elev) }
      let sizePlanRotated : (CGSize) -> CGSize3 = { CGSize3(width: $0.height, depth: $0.width, elev: graph.bounds.elev) }
      let sizeFront : (CGSize) -> CGSize3 = { CGSize3(width: $0.width, depth: graph.bounds.depth, elev: $0.height) }
      let sizeSide : (CGSize) -> CGSize3 = { CGSize3(width: graph.bounds.width, depth:$0.width, elev: $0.height) }
      
      let planMap = [GraphEditingView( build: sizePlan >>> createScaffolding,
                     size: sizeFromPlanScaff,
                     composite: finalDimComp,
                      origin: originFromFullScaff),
                     
                     GraphEditingView( build: sizePlan >>> createScaffolding,
                                       size: sizeFromPlanScaff,
                                       composite: planGridsToDimensions,
                                       origin: originFromFullScaff)
                     ]
      
      let planMapRotated = [GraphEditingView( build: sizePlanRotated >>> createScaffolding,
                           size: sizeFromRotatedPlanScaff,
                           composite: { $0.planEdgesNoZeros |> rotateGroup } >>> curry(planEdgeToGeometry),
                           origin: originFromFullScaff)]
      
      let frontMap = [GraphEditingView( build: sizeFront >>> createScaffolding,
                                        size: sizeFromFullScaff,
                                        composite: { $0.frontEdgesNoZeros } >>> curry(modelToTexturesElev),
                                        origin: originFromFullScaff),
                      
                      GraphEditingView( build: sizeFront >>> createGrid,
                                        size: sizeFromGridScaff,
                                        composite: { $0.frontEdgesNoZeros } >>> curry(modelToTexturesElev),
                                        origin: originFromGridScaff),
                      
                      GraphEditingView( build: sizeFront >>> createScaffolding,
                                        size: sizeFromFullScaff,
                                        composite: { $0.frontEdgesNoZeros } >>> curry(modelToLinework),
                                        origin: originFromFullScaff),
                      
                      GraphEditingView( build: sizeFront >>> createGrid,
                                        size: sizeFromGridScaff,
                                        composite: { $0.frontEdgesNoZeros } >>> curry(modelToLinework),
                                        origin: originFromGridScaff)]
        

      let sideMap = [GraphEditingView( build: sizeSide >>> createScaffolding,
                                       size: sizeFromFullScaffSide,
                                       composite: { $0.sideEdgesNoZeros} >>> curry(modelToTexturesElev),
                                       origin: originFromFullScaff)]
      
      
      
      let uL = SpriteScaffViewController(graph: graph, mapping: planMap)
      let uR = SpriteScaffViewController(graph: graph, mapping: planMapRotated)
      let ll = SpriteScaffViewController(graph: graph, mapping: frontMap)
      let lr = SpriteScaffViewController(graph: graph, mapping: sideMap)
      self.window?.rootViewController = VerticalController(upperLeft: uL, upperRight: uR, lowerLeft: ll, lowerRight: lr)
      
      
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

