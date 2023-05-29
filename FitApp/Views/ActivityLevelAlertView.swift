//
//  ActivityLevelAlertView.swift
//  FitApp
//
//  Created by Ofir Elias on 22/05/2023.
//

import SwiftUI

struct ActivityLevelAlertView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    private var minSteps: Double = 100
    private var maxSteps: Double = 30000
    
    private var minKilometers: Double = 0.1
    private var maxKilometers: Double = 25.01
    
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("רמת פעילות")
                .font(Font.custom(K.Fonts.semiBold, size: 20))
                .foregroundColor(Color(.projectTail))
                .padding()
            
            switch viewModel.viewType {
            case .activity:
                ActivityView
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            case .lifeStyle:
                LifeStyleView
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            }
            
            HStack {
                let buttonWidth: CGFloat = 80
                let buttonHeight: CGFloat = 40
                
                Button {
                    withAnimation {
                        switch viewModel.viewType {
                        case .activity:
                            viewModel.viewType = .lifeStyle
                        case .lifeStyle:
                            viewModel.viewType = .activity
                        }
                    }
                } label: {
                    Text(viewModel.unownButtonText)
                        .font(.custom(K.Fonts.regularText, size: 15))
                        .foregroundColor(Color(.projectTail))
                }
                .frame(width: buttonWidth, height: buttonHeight)
                
                Spacer()
                
                RoundedButton(text: "ביטול", width: buttonWidth, height: buttonHeight, isFull: false) {
                    dismissPopup()
                }
                RoundedButton(text: "שמירה", width: buttonWidth, height: buttonHeight, isFull: true) {
                    viewModel.confirmeChanges() { didChange, type in
                        if didChange {
                            UserProfile.updateServer()
                            action()
                            dismissPopup()
                        } else {
                            guard let type else { return }
                            let typeText = (type == .kilometers) ? "קילומטרים" : "צעדים"
                            
                            GeneralAlertPopupView(titleText: "אופס", subTitleText: "נראה ששחכת להזין מספר \(typeText)").showPopup()
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding()
    }
    
    var stepsFormat: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        return numberFormatter
    }
    var kilometersFormat: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumIntegerDigits = 1
        return numberFormatter
    }
    
    var ActivityView: some View {
        VStack(alignment: .leading) {
            CheckBoxWithSliderView(title: "קילומטרים",
                                   minSliderValue: minKilometers,
                                   maxSliderValue: maxKilometers,
                                   counterFormat: kilometersFormat,
                                   value: $viewModel.kilometersValue,
                                   isChecked: $viewModel.isKilometeresChecked) {
                viewModel.toggleActivity(for: .kilometers)
            }
            
            Divider()
            
            CheckBoxWithSliderView(title: "צעדים",
                                   minSliderValue: minSteps,
                                   maxSliderValue: maxSteps,
                                   counterFormat: stepsFormat,
                                   value: $viewModel.stepsValue,
                                   isChecked: $viewModel.isStepsChecked) {
                viewModel.toggleActivity(for: .steps)
            }
        }
        .padding()
    }
    var LifeStyleView: some View {
        
        VStack(alignment: .leading) {
            ForEach(0..<ViewModel.LifeStyleOptions.allCases.count, id: \.self) { index in
                let isChecked = $viewModel.selectedOption[index]
                let option = ViewModel.LifeStyleOptions.allCases[index]
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Toggle(isOn: isChecked, label: {
                        Text(option.rawValue)
                            .font(.custom(K.Fonts.regularText, size: 15))
                    })
                    .toggleStyle(
                        CheckboxStyle(type: .circle, checkmarkSize: 26, checkmarkWight: .medium, action: {
                            viewModel.toggleBooleanArray(excluding: index)
                        })
                    )
                    .padding(.bottom, 12)
                    VStack {
                        Text(viewModel.getOptionTextFor(option))
                            .font(.custom(K.Fonts.regularText, size: 15))
                    }
                }
                Divider()
            }
        }
        .padding()
    }
}

struct ActivityLevelAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityLevelAlertView() {}
    }
}
