//
//  RoundedButton.swift
//  FitApp
//
//  Created by Ofir Elias on 28/05/2023.
//

import UIKit
import SwiftUI

struct RoundedButton: View {
    
    let text: String
    let width: CGFloat
    let height: CGFloat
    let isFull: Bool
    
    let action: ()->Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(text)
                .frame(minWidth: 0, maxWidth: .infinity)
                .font(.custom(K.Fonts.regularText, size: 15))
                .foregroundColor(Color(uiColor: isFull ? .white : .projectTail))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadious)
                        .stroke(Color(uiColor: .projectTail), lineWidth: 1)
                        .frame(height: height)
                )
        }
        .background(Color(uiColor: isFull ? .projectTail : .white))
        .frame(width: width, height: height)
        .cornerRadius(cornerRadious)
    }
    var cornerRadious: CGFloat {
        height/2
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton(text: "כפתור", width: 100, height: 40, isFull: true){}
    }
}
