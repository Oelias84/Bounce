//
//  GeneralAlertPopup.swift
//  FitApp
//
//  Created by Ofir Elias on 29/05/2023.
//

import SwiftUI

struct GeneralAlertPopupView: View {
    
    let titleText: String
    var subTitleText: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(titleText)
                .font(Font.custom(K.Fonts.semiBold, size: 22))
                .foregroundColor(Color(.projectTail))
                .padding()
            
            Text(subTitleText)
                .multilineTextAlignment(.center)
                .font(Font.custom(K.Fonts.semiBold, size: 16))
                .foregroundColor(Color(.projectTail))
                .padding(.horizontal, 26)
            
            HStack(spacing: 26) {
                let buttonWidth: CGFloat = 80
                let buttonHeight: CGFloat = 40
                
                RoundedButton(text: "אישור", width: buttonWidth, height: buttonHeight, isFull: true) {
                    dismissPopup()
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding()
    }
}

struct GeneralAlertPopup_Previews: PreviewProvider {
    static var previews: some View {
        GeneralAlertPopupView(titleText: "אופס", subTitleText: "נראה ששחכתם לעדכןנראה ששחכתם לעדכןנראה ששחכתם לעדכןנראה ששחכתם לעדכן")
    }
}
