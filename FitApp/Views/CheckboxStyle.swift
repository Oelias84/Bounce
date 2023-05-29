//
//  CheckboxStyle.swift
//  FitApp
//
//  Created by Ofir Elias on 29/05/2023.
//

import SwiftUI

struct CheckboxStyle: ToggleStyle {
    
    enum FrameType: String {
        case circle
        case square
    }
    
    let type: FrameType
    let checkmarkSize: CGFloat
    let checkmarkWight: Font.Weight
    
    let action: (()->Void)
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            action()
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.\(type.rawValue)" : "\(type.rawValue)")
                    .font(.system(size: checkmarkSize, weight: checkmarkWight))
                    .foregroundColor(Color(.projectTail))
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
