//
//  SSCheckBoxesController.swift
//  TestApp
//
//  Created by appzcapple on 2018/03/06.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import UIKit

/// RadioButtonControllerDelegate. Delegate optionally implements didSelectButton that receives selected button.
@objc protocol SSCheckBoxesControllerDelegate {
    /**
        This function is called when a button is selected. If 'shouldLetDeSelect' is true, and a button is deselected, this function
    is called with a nil.
    
    */
    @objc func didSelectButton(selectedButton: UIButton?)
}

class SSCheckBoxesController : NSObject
{
    var buttonsArray = [UIButton]()
    weak var delegate : SSCheckBoxesControllerDelegate? = nil
    /**
        Set whether a selected radio button can be deselected or not. Default value is false.
    */
    var shouldLetDeSelect = true
    /**
        Variadic parameter init that accepts UIButtons.

        - parameter buttons: Buttons that should behave as Radio Buttons
    */
    init(buttons: UIButton...) {
        super.init()
        for aButton in buttons {
            aButton.addTarget(self, action: #selector(SSCheckBoxesController.pressed(_:)), for: UIControlEvents.touchUpInside)
        }
        self.buttonsArray = buttons
    }
    /**
        Add a UIButton to Controller

        - parameter button: Add the button to controller.
    */
    func addButton(_ aButton: UIButton) {
        buttonsArray.append(aButton)
        aButton.addTarget(self, action: #selector(SSCheckBoxesController.pressed(_:)), for: UIControlEvents.touchUpInside)
    }
    /** 
        Remove a UIButton from controller.

        - parameter button: Button to be removed from controller.
    */
    func removeButton(_ aButton: UIButton) {
        var iteratingButton: UIButton? = nil
        if(buttonsArray.contains(aButton))
        {
            iteratingButton = aButton
        }
        if(iteratingButton != nil) {
            buttonsArray.remove(at: buttonsArray.index(of: iteratingButton!)!)
            iteratingButton!.removeTarget(self, action: #selector(SSCheckBoxesController.pressed(_:)), for: UIControlEvents.touchUpInside)
            iteratingButton!.isSelected = false
        }
    }
    /**
        Set an array of UIButons to behave as controller.
        
        - parameter buttonArray: Array of buttons
    */
    func setButtonsArray(_ aButtonsArray: [UIButton]) {
        for aButton in aButtonsArray {
            aButton.addTarget(self, action: #selector(SSCheckBoxesController.pressed(_:)), for: UIControlEvents.touchUpInside)
        }
        buttonsArray = aButtonsArray
    }

    @objc func pressed(_ sender: UIButton) {
        var currentSelectedButton: UIButton? = nil
        if(sender.isSelected) {
            if shouldLetDeSelect {
                sender.isSelected = false
                currentSelectedButton = nil
            }
        } else {
            sender.isSelected = true
            currentSelectedButton = sender
        }
        delegate?.didSelectButton(selectedButton: currentSelectedButton)
    }
    /**
        Get the currently selected button.
    
        - returns: Currenlty selected button.
    */
    func selectedButtons() -> [UIButton]? {
        var selectedButtons = [UIButton]()
        for btn in buttonsArray {
            if btn.isSelected {
                selectedButtons.append(btn)
            }
        }
        return selectedButtons
    }
}
