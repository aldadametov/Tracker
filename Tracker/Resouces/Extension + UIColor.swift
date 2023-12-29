//
//  Extensions.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 16.09.2023.
//

import UIKit

extension UIColor {
    static var ypGreen: UIColor { UIColor(named: "YP Green") ?? UIColor.green }
    static var ypBlue: UIColor { UIColor(named: "YP Blue") ?? UIColor.blue }
    static var ypRed: UIColor { UIColor(named: "YP Red") ?? UIColor.red }
    static var ypBlack: UIColor { UIColor(named: "YP Black") ?? UIColor.black}
    static var ypBackgroundDay: UIColor { UIColor(named: "YP BackgroundDay") ?? UIColor.lightGray }
    static var ypBackgroundNight: UIColor { UIColor(named: "YP BackgroundNight") ?? UIColor.darkGray }
    static var ypGray: UIColor { UIColor(named: "YP Gray") ?? UIColor.gray }
    static var ypLightGray: UIColor { UIColor(named: "YP LightGray") ?? UIColor.lightGray }
    static var ypWhite: UIColor { UIColor(named: "YP White") ?? UIColor.white}
    static let colorSelection: [UIColor] = [
        UIColor(named: "Color Selection 1") ?? .red,
        UIColor(named: "Color Selection 2") ?? .orange,
        UIColor(named: "Color Selection 3") ?? .blue,
        UIColor(named: "Color Selection 4") ?? .magenta,
        UIColor(named: "Color Selection 5") ?? .purple,
        UIColor(named: "Color Selection 6") ?? .systemPink,
        UIColor(named: "Color Selection 7") ?? .systemPink,
        UIColor(named: "Color Selection 8") ?? .systemTeal,
        UIColor(named: "Color Selection 9") ?? .blue,
        UIColor(named: "Color Selection 10") ?? .blue,
        UIColor(named: "Color Selection 11") ?? .orange,
        UIColor(named: "Color Selection 12") ?? .systemPink,
        UIColor(named: "Color Selection 13") ?? .orange,
        UIColor(named: "Color Selection 14") ?? .blue,
        UIColor(named: "Color Selection 15") ?? .purple,
        UIColor(named: "Color Selection 16") ?? .magenta,
        UIColor(named: "Color Selection 17") ?? .purple,
        UIColor(named: "Color Selection 18") ?? .green
    ]
}

extension UIColor {
    func isEqualToColor(_ color: UIColor, withTolerance tolerance: Float = 0.0) -> Bool {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)

        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return fabs(Float(red1 - red2)) <= tolerance && fabs(Float(green1 - green2)) <= tolerance &&
               fabs(Float(blue1 - blue2)) <= tolerance && fabs(Float(alpha1 - alpha2)) <= tolerance
    }
}



