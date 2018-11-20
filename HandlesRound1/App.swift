//
//  App.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Singalong
import Graphe
import Volume
@testable import FormsCopy

typealias Length = Measurement<UnitLength>

func feet(_ len: Length) -> (Int, Length) {
  let feetLen = len.converted(to: .feet)
  let roundedDown = feetLen.value.rounded(.down)
  return  (Int( roundedDown ), Length(value: feetLen.value - roundedDown, unit: .feet))
}

func inches(_ len: Length) -> (Int, Length) {
  let inchLen = len.converted(to: .inches)
  let roundedDown = inchLen.value.rounded(.down)
  return  (Int( roundedDown ), Length(value: inchLen.value - roundedDown, unit: .inches))
}

func inchesFraction(_ len: Length) -> ((Int, Int), Length) {
  let base = 8.0
  let inchLen = len.converted(to: .inches)
  let rounded = (inchLen.value*base).rounded()
  return  ( (Int( rounded ), Int( base )) , Length(value: inchLen.value - rounded/base, unit: .inches))
}

func gcd(_ a:Int, _ b:Int) -> Int {
  func mod(_ a: Int, _ b: Int) -> Int {
    return a - b * abs( a/b )
  }
  if b == 0 { return a }
  else {
    return gcd(b, mod(a, b) )
  }
}

func simplify( numerator:Int, denominator:Int)  -> (Int, Int)? {
  if numerator == 0 { return nil }
  else {
    let divsor = gcd(numerator, denominator)
    return (numerator/divsor, denominator/divsor)
  }
}

let imperialFormatter : (Measurement<UnitLength>) -> String = {
  let ft = feet($0)
  let i = inches(ft.1)
  let fr = inchesFraction(i.1)
  let sim = simplify(numerator: fr.0.0, denominator: fr.0.1)
  let simS = sim.map { return " \($0.0)/\($0.1)" }
  return "\(ft.0)'-\(i.0)\(simS ?? "")\""
}

let metricFormatter : (Measurement<UnitLength>) -> String = {
  let meters = $0.converted(to: .meters)
  return "\( String(format: "%.2f", meters.value) ) m"
}




extension ScaffGraph {
  var width : Measurement<UnitLength> {
    return (grid.pX.max()! |> Double.init, .centimeters) |> Measurement<UnitLength>.init(value:unit:)
  }
  var depth : Measurement<UnitLength> {
    return (grid.pY.max()! |> Double.init, .centimeters) |> Measurement<UnitLength>.init(value:unit:)
  }
  var height : Measurement<UnitLength> {
    return (grid.pZ.max()! |> Double.init, .centimeters) |> Measurement<UnitLength>.init(value:unit:)
  }
  var ledgers : Int {
    return edges.filtered(by: isLedger).count
  }
  var diags : Int {
    return edges.filtered(by: isDiag).count
  }
  var collars : Int {
    return edges.filtered(by: isPoint).count
  }
  var standards : Int {
    return edges.filtered(by: isVertical).count
  }
}



let graphForm: Form<Item<ScaffGraph>> =
  sections([
    section([
      nestedTextField(title: "Name", keyPath: \.name),
      labelCell(title: "Ledgers", label:  intLabel(keyPath: \.content.ledgers), leftAligned: false),
      ]),
])

let colorsForm: Form<Item<ScaffGraph>> =
  sections([
    section([
     nestedTextField(title: "Name", keyPath: \.name)
     ]),
    section([
      labelCell(title: "Ledgers", label:  intLabel(keyPath: \.content.ledgers), leftAligned: false),
      labelCell(title: "Diags", label:  intLabel(keyPath: \.content.diags), leftAligned: false),
      labelCell(title: "Collars", label:  intLabel(keyPath: \.content.collars), leftAligned: false),
      labelCell(title: "Standards", label:  intLabel(keyPath: \.content.standards), leftAligned: false)
      ]),
    section([
      labelCell(title: "Width", label:  dimLabel(keyPath: \.content.width, formatter: metricFormatter), leftAligned: false),
      labelCell(title: "Depth", label:  dimLabel(keyPath: \.content.depth, formatter: metricFormatter), leftAligned: false),
      labelCell(title: "Height", label:  dimLabel(keyPath: \.content.height, formatter: metricFormatter), leftAligned: false),
      ]),
    section([
      labelCell(title: "Width", label:  dimLabel(keyPath: \.content.width, formatter: imperialFormatter), leftAligned: false),
      labelCell(title: "Depth", label:  dimLabel(keyPath: \.content.depth, formatter: imperialFormatter), leftAligned: false),
      labelCell(title: "Height", label:  dimLabel(keyPath: \.content.height, formatter: imperialFormatter), leftAligned: false),

      ]),
    ])

public class App {
  public init() {
  }
  
  public lazy var rootController: UIViewController = loadEntryTable
  public lazy var mock : ()->(UIViewController) = {
    let nav = embedInNav(GraphNavigator(id: "Mock0").vc)
    styleNav(nav)
    return nav
  }
  
  var editViewController : EditViewController<Item<ScaffGraph>, UITableViewCell>?
  var inputTextField : UITextField?

  
  lazy var loadEntryTable : UINavigationController  = {
    let load = Current.file.load()
    
    switch load {
    case let .success(value):
      
      Current.model = value
    case let .error(error):
      Current.model = ItemList.mock
    }
      
      
      let edit = EditViewController(
        config: EditViewContConfiguration(
          initialValue: Current.model.contents)
        { (anItem:Item<ScaffGraph> , cell: UITableViewCell) -> UITableViewCell in
          cell.textLabel?.text = anItem.name
          cell.accessoryType = .detailDisclosureButton
          return cell
        }
      )
      edit.didSelect = { (item, cell) in
        self.currentNavigator = GraphNavigator(id: cell.id)
        self.loadEntryTable.pushViewController(self.currentNavigator.vc, animated: true)
      }
      edit.didSelectAccessory = { (item, cell) in
        let driver = FormDriver(initial: cell, build: colorsForm)
        driver.formViewController.navigationItem.largeTitleDisplayMode = .never
        self.loadEntryTable.pushViewController(driver.formViewController, animated: true)
        
      }
      edit.topRightBarButton = BarButtonConfiguration(type: .system(.add)) {
        func addTextField(_ textField: UITextField!){
          // add the text field and make the result global
          textField.placeholder = "Definition"
          self.inputTextField = textField
        }
        
        let listNamePrompt = UIAlertController(title: "Name your list", message: nil, preferredStyle: UIAlertController.Style.alert)
        listNamePrompt.addTextField(configurationHandler: addTextField)
        listNamePrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: ({ (ui:UIAlertAction) -> Void in
          
        })))
        listNamePrompt.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.default, handler: ({ (ui:UIAlertAction) -> Void in
          let text = self.inputTextField?.text ?? "Default"
          print(text)
          let new : Item<ScaffGraph> = Item(content: (200,200,200) |> createScaffolding, id: text, name: text)
          Current.model.addOrReplace(item: new)
          Current.file.save(Current.model)
          edit.undoHistory.currentValue = Current.model.contents
        })))
        
        self.rootController.present(listNamePrompt, animated: true, completion: nil)
      }
      edit.title = "Deploy" // Moditive
      // Formosis // Formicate, Formite, Formate, Form Morph, UnitForm, Formunit
      // Morpho, massing, Meccano, mechanized, modulus, Moduform, Modju, Mojuform, Majuform
      // Modulo
      self.editViewController = edit
      let nav = UINavigationController(rootViewController: edit)
      styleNav(nav)
      return nav
    
    
  
    
  }()
  var currentNavigator : GraphNavigator!
}






