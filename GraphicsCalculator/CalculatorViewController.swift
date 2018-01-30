//
//  ViewController.swift
//  GraphicsCalculator
//
//  Created by Анастасия Соколан on 29.12.17.
//  Copyright © 2017 Анастасия Соколан. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var point: UIButton! {
        didSet {
            point.setTitle(decimalSeparator, for: UIControlState())
        }
    }
    let decimalSeparator = formatter.decimalSeparator ?? "."

    private var userIsInWriting = false
    
    private var displayValue: Double? {
        get {
            if let text = display.text, let value = formatter.number(from: text) as? Double {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.string(from: NSNumber(value:value))
            }
            
            if let description = brain.description {
                history.text = description + (brain.resultIsPending ? " …" : " =")
            }
        }
    }
    private lazy var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInWriting {
            if let displayNum = displayValue  {
                brain.setOperand(operand: displayNum)
                userIsInWriting = false
            }
        }
        if let operation = sender.currentTitle {
            brain.performOperation(symbol: operation)
        }
        displayValue = brain.result
    }

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInWriting {
            let textCurrentlyDisplay = display.text!;
            if digit != "⋅" || !(textCurrentlyDisplay.contains("⋅")) {
                display.text = textCurrentlyDisplay + digit
            }
        }
        else {
            display.text = digit
        }
        userIsInWriting = true
    }
    @IBAction func clearAll(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        history.text = " "
    }
}

