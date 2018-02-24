//
//  AppDelegate.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit





struct GraphEditingView {
  let build: (CGSize) -> (GraphPositions, [Edge])
  let size : (ScaffGraph) -> CGSize
  let composite : (ScaffGraph) -> (CGPoint) -> [Geometry]
  let origin : (ScaffGraph, CGRect, CGFloat) -> CGPoint
}

let ccccc = 20.0 |>> (dimPoints2, [[CGPoint(0,0)]] )
let front1 : (ScaffGraph) -> (CGPoint) -> [Geometry] = { $0.frontEdgesNoZeros } >>> curry(modelToTexturesElev)
let front2 : (ScaffGraph) -> (CGPoint) -> [Geometry] = { $0.grid } >>> graphToNonuniformFront >>> dimensons
let outerInterim : (ScaffGraph) -> [C2Edge] = { ($0.grid, $0.edges) |> frontSection().parse }
let outerDimensions =
  edgesToPoints >>> removeDup >>> log >>>
    leftToRightDict >>> log >>>
    pointDictToArray >>> log
let outer4 =
  leftToRightToBordersArray >>> log >>>
    {($0, 20)} >>>
    dimPoints2 >>> log
let outerDimPlus : (ScaffGraph) -> (CGPoint) -> [Geometry] =
  outerInterim >>> outerDimensions >>> outer4 >>> { g in return {p in return g.map { ($0, p.asVector()) |> move } } }

let frontFinal = front1 <> outerDimPlus

func graphViewList(
  build: @escaping (CGSize) -> (GraphPositions, [Edge]),
  size : @escaping (ScaffGraph) -> CGSize,
  composite : [(ScaffGraph) -> (CGPoint) -> [Geometry]],
  origin : @escaping (ScaffGraph, CGRect, CGFloat) -> CGPoint
  )-> [GraphEditingView]
{
  return composite.map {
    GraphEditingView( build: build,
                      size: size,
                      composite: $0,
                      origin: origin)
  }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
      self.window = UIWindow(frame: UIScreen.main.bounds)

      self.window?.makeKeyAndVisible()
      
      
      
      let postis = CGSize3(width: 100, depth: 100, elev: 100) |> createGrid
      let graph = ScaffGraph(grid: postis.0, edges: postis.1)
      
      let sizePlan : (CGSize) -> CGSize3 = { CGSize3(width: $0.width, depth: $0.height, elev: graph.bounds.elev) }
      
      let planMap = graphViewList( build: sizePlan >>> createScaffolding,
                     size: sizeFromPlanScaff,
                     composite: [finalDimComp, planGridsToDimensions, frontFinal],
                      origin: originFromFullScaff)
      
      self.window?.rootViewController = SpriteScaffViewController(graph: graph, mapping: planMap)
      
      
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

