//
//  EdgePredicates.swift
//  Graph
//
//  Created by Justin Smith on 11/16/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Singalong

/// Use case
/*
 *isLedger*
 isXLedger || isYLedger
 
 (Edge -> Bool || Edge -> Bool)    -> Bool
 
 *isDiag*
 hasXChange && hasZChange
 (Edge -> Bool && Edge -> Bool)    -> Bool
 
 edges.filtered(by: isLedger).count
 [Edge<ScaffType>]
 
 
 edges.filtered(by: (xBay(bayIndex.x) && zBay(bayIndex.y)) && (edgeXDiagUp || edgeXDiagDown))
*/

import GrapheNaked

func delta(axis: KeyPath<PointIndex, Int>, edge: Edge<ScaffType>)-> Int {
  return edge.p2[keyPath: axis] - edge.p1[keyPath: axis]
}

func deltaG<T>(axis: KeyPath<PointIndex, Int>, edge: Edge<T>)-> Int {
  return edge.p2[keyPath: axis] - edge.p1[keyPath: axis]
}




public func isXLedger2<T>()-> Predicate<Edge<T>>{
  return Predicate { (e: Edge<T>) -> Bool in
  return abs(deltaG(axis:\.xI, edge: e)) == 1
    && abs(deltaG(axis:\.zI, edge: e)) == 0
    && abs(deltaG(axis:\.yI, edge: e)) == 0
    ? true : false
  }
}
  

public let isXLedger : Predicate<ScaffEdge> = Predicate { (e: Edge) -> Bool in
  return abs(delta(axis:\.xI, edge: e)) == 1
    && abs(delta(axis:\.zI, edge: e)) == 0
    && abs(delta(axis:\.yI, edge: e)) == 0
    ? true : false
}

public let isYLedger : Predicate<ScaffEdge> = Predicate { (e: Edge) -> Bool in
  return abs(delta(axis:\.yI, edge: e)) == 1
    && abs(delta(axis:\.zI, edge: e)) == 0
    && abs(delta(axis:\.xI, edge: e)) == 0
    ? true : false
}

public let hasXChange : Predicate<ScaffEdge> = Predicate { (e: Edge) -> Bool in
  return abs(delta(axis:\.xI, edge: e)) >= 1
    ? true : false
}

public let hasYChange : Predicate<ScaffEdge> = Predicate { (e: Edge) -> Bool in
  return abs(delta(axis:\.yI, edge: e)) >= 1
    ? true : false
}

public let hasZChange : Predicate<ScaffEdge> = Predicate { (e: Edge) -> Bool in
  return abs(delta(axis:\.zI, edge: e)) >= 1
    ? true : false
}


public let isVertical : Predicate<ScaffEdge> = hasZChange && !hasYChange && !hasXChange
public let isPoint : Predicate<ScaffEdge> = !hasXChange && !hasYChange && !hasZChange
public let isDiag : Predicate<ScaffEdge> = hasXChange && hasZChange || hasYChange && hasZChange
public let isLedger : Predicate<ScaffEdge> = isXLedger || isYLedger
