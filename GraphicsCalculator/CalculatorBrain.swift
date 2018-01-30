//
//  File.swift
//  GraphicsCalculator
//
//  Created by Анастасия Соколан on 29.12.17.
//  Copyright © 2017 Анастасия Соколан. All rights reserved.
//

import Foundation

class CalculatorBrain {
    var result: Double? {
        get {
            return accumulator
        }
    }
    private var accumulator: Double?
    
    private var descriptionAccumulator: String?
    var description: String? {
        get {
            if pending == nil {
                return descriptionAccumulator
            }
            else {
                return pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator ?? "")
            }
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(Double.pi),
        "e" : Operation.Constant(M_E),
        "sin" : Operation.UnaryOper(sin, nil),
        "cos" : Operation.UnaryOper(cos, nil),
        "tg" : Operation.UnaryOper(tan, nil),
        "ctg" : Operation.UnaryOper({1/tan($0)}, nil),
        "√" : Operation.UnaryOper(sqrt, nil),
        "±" : Operation.UnaryOper({-$0}, nil),
        "−" : Operation.BinaryOper({$0 - $1}, nil),
        "+" : Operation.BinaryOper({$0 + $1}, nil),
        "÷" : Operation.BinaryOper({$0 / $1}, nil),
        "×" : Operation.BinaryOper({$0 * $1}, nil),
        "=" : Operation.Equals
    ]
    private var pending: PendingBinaryOperationInfo?
    private enum Operation {
        case Constant(Double)
        case BinaryOper((Double, Double) -> Double, ((String, String) -> String)?)
        case UnaryOper((Double) -> Double, ((String) -> String)?)
        case Equals
    }
    private struct PendingBinaryOperationInfo {
        var binaryFunc: (Double, Double) -> Double
        var firstOper: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        func performDescription (with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        if let value = accumulator {
            descriptionAccumulator = formatter.string(from: NSNumber(value:value)) ?? ""
        }
    }
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .BinaryOper(let function, var descriptionFunc):
                executePendingBinOper()
                if accumulator != nil {
                    if descriptionFunc == nil {
                        descriptionFunc = {$0 + " " + symbol + " " + $1}
                    }
                }
                pending = PendingBinaryOperationInfo(binaryFunc: function, firstOper: accumulator!, descriptionFunction: descriptionFunc!, descriptionOperand: descriptionAccumulator!)
                accumulator = nil
                descriptionAccumulator = nil
                break
            case .UnaryOper(let function, var descriptionFunc):
                if let value = accumulator {
                    accumulator = function(value)
                    if  descriptionFunc == nil{
                        descriptionFunc = {symbol + "(" + $0 + ")"}
                    }
                    descriptionAccumulator = descriptionFunc!(descriptionAccumulator!)
                }
                break
            case .Constant(let associatedVal):
                accumulator = associatedVal
                descriptionAccumulator = symbol
                break
            case .Equals:
                executePendingBinOper()
                break
            }
        }
    }
    private func executePendingBinOper() {
        if pending != nil && accumulator != nil {
            accumulator = pending!.binaryFunc(pending!.firstOper, accumulator!)
            descriptionAccumulator = pending!.performDescription(with: descriptionAccumulator!)
            pending = nil
        }
    }
    
    func clear() {
        accumulator = nil
        pending = nil
        descriptionAccumulator = " "
    }
    var resultIsPending: Bool {
        get {
            return pending != nil
        }
    }
}

let formatter:NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    formatter.notANumberSymbol = "Error"
    formatter.groupingSeparator = " "
    formatter.locale = Locale.current
    return formatter
    
} ()
