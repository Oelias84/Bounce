//
//  CheckBoxWithSliderView.swift
//  FitApp
//
//  Created by Ofir Elias on 28/05/2023.
//

import SwiftUI

struct CheckBoxWithSliderView: View {
    
    let title: String
    let minSliderValue: Double
    let maxSliderValue: Double
    let counterFormat: NumberFormatter
    
    @Binding var value: Double
    @Binding var isChecked: Bool

    let action: ()->Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Toggle(isOn: $isChecked) {
                    Text(title)
                        .font(Font.custom(K.Fonts.regularText, size: 16))
                }
                .toggleStyle(CheckboxStyle(type: .circle, checkmarkSize: 26, checkmarkWight: .medium, action: action))
                .padding(.bottom, 12)
                
                Spacer()
                
                Text("\(formattedValue)")
                    .font(Font.custom(K.Fonts.regularText, size: 16))
            }
            
            Slider(value: $value, in: minSliderValue...maxSliderValue, step: 0.1)
                .accentColor(Color(uiColor: .projectTail))
        }
    }
    
    var formattedValue: String {
        return counterFormat.string(from: NSNumber(value: value)) ?? ""
    }
}

struct CheckBoxWithSliderView_Previews: PreviewProvider {
    
    static var stepsFormat: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        return numberFormatter
    }
    static var previews: some View {
        @State var value: Double = 0
        
        CheckBoxWithSliderView(title: "כותרת",
                               minSliderValue: 1,
                               maxSliderValue: 100,
                               counterFormat: stepsFormat,
                               value: $value,
                               isChecked: .constant(true),
                               action: {})
    }
}
