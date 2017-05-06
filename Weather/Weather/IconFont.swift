//
//  IconFont.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 07/03/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit
/*
 <string name="clear_day_icon">\uF00D</string>
 <string name="clear_night_icon">\uF02E</string>
 <string name="rain_icon">\uF01D</string>
 <string name="snow_icon">\uF017</string>
 <string name="sleet_icon">\uF01B</string>
 <string name="wind_icon">\uF050</string>
 <string name="fog_icon">\uF014</string>
 <string name="cloudy_icon">\uF013</string>
 <string name="partly_cloudy_day_icon">\uF002</string>
 <string name="partly_cloudy_night_icon">\uF086</string>
 <string name="thunderstorm_icon">\uF016</string>
 <string name="tornado_icon">\uF056</string>
 */
public enum WeatherUnicode: UInt32 {
    case clear =  0xF00D
    case rain = 0xF01D
    case snow = 0xF017
    case sleet = 0xF01B
    case wind = 0xF050
    case fog = 0xF014
    case cloudy = 0xF013
    case thunderstorm = 0xF016
    case tornado = 0xF056
}

public enum Weather: String {
    case clear
    case sunny
    case rain
    case snow
    case sleet
    case wind
    case fog
    case cloudy
    case thunderstorms
    case tornado
}

public final class WeatherIconFont {
    
    private static func iconFont(_ size: CGFloat) -> UIFont? {
        if size == 0.0 {
            return nil
        }
        let iconfont = "weathericons-regular"
        loadMyCustomFont(iconfont)
        return UIFont(name: iconfont, size: size)
    }
    
    private static func loadMyCustomFont(_ name:String) {
        guard let fontPath = Bundle(for: WeatherIconFont.self).path(forResource: name, ofType: "ttf") else {
            return
        }
        
        var error: Unmanaged<CFError>?
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fontPath)),
            let provider = CGDataProvider(data: data as CFData) else {
            return
        }
        
        let font = CGFont(provider)
        CTFontManagerRegisterGraphicsFont(font, &error) 
    }
    
    private static func stringForIcon(_ unicode : WeatherUnicode) -> String? {
        var rawUnicode = unicode.rawValue;
        let xPtr = withUnsafeMutablePointer(to: &rawUnicode, { $0 })
        return String(bytesNoCopy: xPtr, length:MemoryLayout<UInt32>.size, encoding: String.Encoding.utf32LittleEndian, freeWhenDone: false)
    }
    
    public static func string(fromUnicode unicode: WeatherUnicode, size: CGFloat = CGFloat(12), color: UIColor?) -> NSAttributedString? {
        
        guard let font = WeatherIconFont.iconFont(size) ,
            let string = stringForIcon(unicode) else { return nil }
        
        var attributes = [String : AnyObject]()
        attributes[NSFontAttributeName] = font
        
        if let color = color {
            attributes[NSForegroundColorAttributeName] = color
        }
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    public static func image(fromUnicode unicode: WeatherUnicode, size: CGFloat, color: UIColor?) -> UIImage? {
        
        if size == 0.0 {
            return nil
        }
        
        guard let symbol = string(fromUnicode: unicode, size: size, color: color) else { return nil }
        
        let mutableSymbol = NSMutableAttributedString(attributedString: symbol)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        mutableSymbol.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, mutableSymbol.length))
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        mutableSymbol.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
