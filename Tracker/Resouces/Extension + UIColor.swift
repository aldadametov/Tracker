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
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}




