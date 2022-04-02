//
//  Constants+Theme.Color.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension Constants.Theme {
  enum Color {}
}

extension Constants.Theme.Color {
  
  enum MarqueColors {
    
    static var standardMarque: UIColor {
      UIColor.from(dark: .init(hex: 0x338DDA),
                   light: .init(hex: 0x337ac7))
    }
  }
  
  enum InteractableElement {
    
    static var standardButtonBackground: UIColor {
      Constants.Theme.Color.MarqueColors.standardMarque
    }
    
    static var standardButtonTint: UIColor {
      Constants.Theme.Color.MarqueColors.standardMarque
    }
    
    static var standardBarButtonTint: UIColor {
      Constants.Theme.Color.ViewElement.Label.titleDark
    }
  }
  
  enum ViewElement {
    
    static var primaryBackground: UIColor {
      UIColor.from(dark: UIColor.secondarySystemBackground,
                   light: UIColor.systemBackground)
    }
    
    static var secondaryBackground: UIColor {
      UIColor.from(dark: UIColor.systemBackground,
                   light: UIColor.secondarySystemBackground)
    }
    
    static var tertiaryBackground: UIColor {
      UIColor.tertiarySystemBackground
    }
    
    static var alert: UIColor {
      Constants.Theme.Color.SystemColor.orange
    }
    
    static var symbolImageLight: UIColor {
      UIColor.from(dark: .init(hex: 0x000000),
                   light: .init(hex: 0xFFFFFF))
    }
    
    static var symbolImageDark: UIColor {
      UIColor.from(dark: .init(hex: 0xFFFFFF),
                   light: .init(hex: 0x000000))
    }
    
    static var cellPrefixSymbolImage: UIColor {
      UIColor.from(dark: .init(hex: 0xFFFFFF),
                   light: .init(hex: 0xFFFFFF))
    }
    
    enum Label {
      
      static var titleLight: UIColor {
        UIColor.from(dark: .init(hex: 0x000000),
                     light: .init(hex: 0xFFFFFF))
      }
      
      static var titleDark: UIColor {
        UIColor.from(dark: .init(hex: 0xFFFFFF),
                     light: .init(hex: 0x000000))
      }
      
      static var bodyLight: UIColor {
        Constants.Theme.Color.SystemColor.gray2
      }
      
      static var bodyDark: UIColor {
        Constants.Theme.Color.SystemColor.gray
      }
      
      static var subtitleLight: UIColor {
        Constants.Theme.Color.SystemColor.gray2
      }
      
      static var subtitleDark: UIColor {
        Constants.Theme.Color.SystemColor.gray
      }
    }
    
    enum WeatherInformation {
      
      static var colorBackgroundPrimaryTitle: UIColor {
        UIColor.from(dark: .init(hex: 0xFFFFFF),
                     light: .init(hex: 0xFFFFFF))
      }
      
      static var colorBackgroundDay: UIColor {
        Constants.Theme.Color.MarqueColors.standardMarque
      }
      
      static var colorBackgroundNight: UIColor {
        UIColor.from(dark: .init(hex: 0xA57DFE),
                     light: .init(hex: 0x66599e))
      }
      
      static var border: UIColor {
        UIColor.from(dark: .init(hex: 0x000000),
                     light: .init(hex: 0xFFFFFF))
      }
      
      static var white: UIColor {
        UIColor.from(dark: .init(hex: 0xFFFFFF),
                     light: .init(hex: 0xFFFFFF))
      }
      
      static var gray: UIColor {
        Constants.Theme.Color.SystemColor.gray
      }
      
      static var blue: UIColor {
        Constants.Theme.Color.SystemColor.blue
      }
      
      static var cyan: UIColor {
        Constants.Theme.Color.SystemColor.cyan
      }
      
      static var red: UIColor {
        Constants.Theme.Color.SystemColor.red
      }
      
      static var yellow: UIColor {
        Constants.Theme.Color.SystemColor.yellow
      }
      
      static var purple: UIColor {
        Constants.Theme.Color.SystemColor.purple
      }
    }
    
    enum CellImage {
      
      static var imageTint: UIColor {
        UIColor.from(dark: .init(hex: 0xFFFFFF),
                     light: .init(hex: 0xFFFFFF))
      }
      
      static var backgroundBlue: UIColor {
        UIColor.systemBlue
      }
      
      static var backgroundGreen: UIColor {
        Constants.Theme.Color.SystemColor.green
      }
      
      static var backgroundRed: UIColor {
        Constants.Theme.Color.SystemColor.red
      }
      
      static var backgroundAmber: UIColor {
        Constants.Theme.Color.SystemColor.orange
      }
      
      static var backgroundYellow: UIColor {
        Constants.Theme.Color.SystemColor.yellow
      }
      
      static var backgroundGray: UIColor {
        Constants.Theme.Color.SystemColor.gray
      }
    }
  }
  
  enum SystemColor {
    
    static var blue: UIColor {
      UIColor.systemBlue
    }
    
    static var green: UIColor {
      UIColor.from(dark: .init(red: 48, green: 209, blue: 88),
                   light: .init(red: 52, green: 199, blue: 89))
    }
    
    static var indigo: UIColor {
      UIColor.from(dark: .init(red: 94, green: 92, blue: 230),
                   light: .init(red: 88, green: 86, blue: 214))
    }
    
    static var orange: UIColor {
      UIColor.from(dark: .init(red: 255, green: 159, blue: 10),
                   light: .init(red: 255, green: 149, blue: 0))
    }
    
    static var pink: UIColor {
      UIColor.from(dark: .init(red: 255, green: 55, blue: 85),
                   light: .init(red: 255, green: 45, blue: 95))
    }
    
    static var purple: UIColor {
      UIColor.from(dark: .init(red: 191, green: 90, blue: 242),
                   light: .init(red: 175, green: 82, blue: 222))
    }
    
    static var red: UIColor {
      UIColor.from(dark: .init(red: 255, green: 69, blue: 58),
                   light: .init(red: 255, green: 59, blue: 48))
    }
    
    static var cyan: UIColor {
      UIColor.from(dark: .init(red: 100, green: 210, blue: 255),
                   light: .init(red: 50, green: 173, blue: 230))
    }
    
    static var teal: UIColor {
      UIColor.from(dark: .init(red: 100, green: 210, blue: 255),
                   light: .init(red: 90, green: 200, blue: 250))
    }
    
    static var yellow: UIColor {
      UIColor.from(dark: .init(red: 255, green: 214, blue: 10),
                   light: .init(red: 255, green: 204, blue: 0))
    }
    
    static var gray: UIColor {
      UIColor.from(dark: .init(red: 142, green: 142, blue: 147),
                   light: .init(red: 142, green: 142, blue: 147))
    }
    
    static var gray2: UIColor {
      UIColor.from(dark: .init(red: 99, green: 99, blue: 102),
                   light: .init(red: 174, green: 174, blue: 178))
    }
    
    static var gray3: UIColor {
      UIColor.from(dark: .init(red: 72, green: 72, blue: 74),
                   light: .init(red: 199, green: 199, blue: 204))
    }
    
    static var gray4: UIColor {
      UIColor.from(dark: .init(red: 58, green: 58, blue: 60),
                   light: .init(red: 209, green: 209, blue: 214))
    }
    
    static var gray5: UIColor {
      UIColor.from(dark: .init(red: 44, green: 44, blue: 46),
                   light: .init(red: 229, green: 229, blue: 234))
    }
    
    static var gray6: UIColor {
      UIColor.from(dark: .init(red: 28, green: 28, blue: 30),
                   light: .init(red: 242, green: 242, blue: 247))
    }
  }
}
