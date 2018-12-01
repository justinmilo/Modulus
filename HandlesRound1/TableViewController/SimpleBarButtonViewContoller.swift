//
//  BarButtonBlocks.swift
//  MaterialSMJ
//
//  Created by Justin Smith on 10/30/16.
//  Copyright © 2016 Justin Smith. All rights reserved.
//

import UIKit

public class SimpleBarButtonViewController : UITableViewController {
    // MARK: Bar Button Items
    // Bar button stuff ...
    var topRightBarButton : BarButtonConfiguration?
        {
        didSet {
            self.navigationItem.rightBarButtonItem = button(from: topRightBarButton)
        }
    }
    var topLeftBarButton : BarButtonConfiguration?
        {
        didSet {
            self.navigationItem.leftBarButtonItem = button(from: topLeftBarButton)
        }
    }
    var toolBarButtons : [BarButtonConfiguration]?
        {
        didSet{
            guard let toolBarButtons = toolBarButtons else { return }
            let barItems = toolBarButtons.compactMap { return button(from:$0)}
            self.setToolbarItems(barItems, animated: false)
        }
    }
    var bottomLeftBarButton : BarButtonConfiguration?
    var bottomRightBarButton : BarButtonConfiguration?
    
    var buttonsAndActions : [(item:UIBarButtonItem, action:()->Void)] = []
    func button(from config: BarButtonConfiguration?) -> UIBarButtonItem?
    {
        var barButton : UIBarButtonItem
        guard let config = config else {
            return nil
        }
        switch config.type
        {
        case .system(let item) :
            barButton = UIBarButtonItem(barButtonSystemItem: item, target: self, action: #selector(self.barButtonTapped(_:)))
        case .custom(let string) :
            barButton = UIBarButtonItem(title: string, style: .plain, target: self, action: #selector(self.barButtonTapped(_:)))
        }
        buttonsAndActions.append( (barButton, config.block) )
        return barButton
    }
    
    @objc func barButtonTapped(_ sender: AnyObject)
    {
        let barButton = sender as! UIBarButtonItem
        for tup in buttonsAndActions {
            if tup.item == barButton
            {
                tup.action()
            }
        }
    }
    // ... end of bar button stuff
    
}
