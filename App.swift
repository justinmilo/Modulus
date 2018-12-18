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





let showPreviewForm: Form<Item<ScaffGraph>> =
  sections([
    section(
      ScaffoldingGridSizes.eventMetric.map { option in
        optionSetCell(title: option.label, option: option, keyPath: \.sizePreferences)
      }
    ),
    section(
      ScaffoldingGridSizes.us.map { option in
        optionSetCell(title: option.label, option: option, keyPath: \.sizePreferences)
      })
    ])

let aSection : Element<Section, Item<ScaffGraph>> = section([
detailTextCell(title: "Notification", keyPath: \.sizePreferences.text, form: showPreviewForm)
], isVisible: \.isEnabled)



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
    section([
      detailTextCell(title: "Bay Sizes", keyPath: \.sizePreferences.text, form: showPreviewForm)
      ], isVisible: \.isEnabled)
    
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
        driver.didUpdate = {
          Current.model.addOrReplace(item: $0)
        }
        self.loadEntryTable.pushViewController(driver.formViewController, animated: true)
        
      }
      edit.topRightBarButton = BarButtonConfiguration(type: .system(.add)) {
        func addTextField(_ textField: UITextField!){
          // add the text field and make the result global
          textField.placeholder = "Definition"
          self.inputTextField = textField
        }
        
        let listNamePrompt = UIAlertController(title: "Name This Structure", message: nil, preferredStyle: UIAlertController.Style.alert)
        listNamePrompt.addTextField(configurationHandler: addTextField)
        listNamePrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: ({ (ui:UIAlertAction) -> Void in
          
        })))
        listNamePrompt.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.default, handler: ({ (ui:UIAlertAction) -> Void in
          let text = self.inputTextField?.text ?? "Default"
          print(text)
          let new : Item<ScaffGraph> = Item(
            content: (Item.template.map{ s in CGFloat( s.length.converted(to:.centimeters).value) }, (200,200,200) |> CGSize3.init) |> createScaffoldingFrom,
            id: text,
            name: text)
          Current.model.addOrReplace(item: new)
          Current.file.save(Current.model)
          edit.undoHistory.currentValue = Current.model.contents
        })))
        
        self.rootController.present(listNamePrompt, animated: true, completion: nil)
      }
      edit.title = "Deploy"
    // Moditive
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






