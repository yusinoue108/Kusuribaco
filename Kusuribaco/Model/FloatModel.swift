//
//  Floats.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/02/02.
//

import Foundation
import SwiftEntryKit

// MARK: -  SwiftEntryKit
class float {
    
    class func show(message: String, width: CGFloat, height: CGFloat) {
        
        // Attributes設定
        var attributes = EKAttributes.bottomFloat
        attributes.entryBackground = .color(color: .init(red: 255, green: 150 , blue: 0))
        
        var animation = EKAttributes.Animation()
        animation.translate = .init(duration: 0.3)
        animation.scale = .init(from: 1.0, to: 0.7, duration: 0.7)
        attributes.popBehavior = .animated(animation: animation)
        
        attributes.positionConstraints.size.height = .constant(value: height)
        attributes.positionConstraints.size.width = .constant(value: width)
        
        // View設定
        let style = EKProperty.LabelStyle(font: .boldSystemFont(ofSize: 14), color: .white)
        let message = EKProperty.LabelContent(text: message, style: style)
        let view = EKNoteMessageView(with: message)
        
        SwiftEntryKit.display(entry: view, using: attributes)
    }
}
