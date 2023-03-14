//
//  SetView.swift
//  FitApp
//
//  Created by Ofir Elias on 27/02/2023.
//

import SwiftUI

struct SetView: View {
	
	enum Field: Hashable {
		case repeatsField
		case weightField
	}
	
	var isDeleteEnabled: Bool
	@Binding var set: SetModel
	@State var isEnabled: Bool = true
    
	@FocusState var focusedField: SetView.Field?
	
	var repeatsPlaceholder: String {
		return String(set.repeats ?? 0)
	}
	var weightsPlaceholder: String {
		return String(set.weight ?? 0)
	}
	
	let action: (UUID?)->()
	
	var body: some View {
		
		HStack() {
			// Set Number
			Text("סט #\(set.setIndex+1)")
				.frame(width: 56)
				.font(Font.custom(K.Fonts.boldText, size: 16))
				.multilineTextAlignment(.trailing)

			// Number of repeats textfield
			Text("חזרות:")
				.font(Font.custom(K.Fonts.regularText, size: 16))
			
			TextField(repeatsPlaceholder, value: $set.repeats, format: .number)
				.focused($focusedField, equals: .repeatsField)
				.keyboardType(.numberPad)
				.multilineTextAlignment(.center)
				.frame(width: 46)
				.textFieldStyle(.roundedBorder)
				.multilineTextAlignment(.center)
			
			// Weight amount textfield
			Text("משקל:")
				.font(Font.custom(K.Fonts.regularText, size: 16))
			TextField(weightsPlaceholder, value: $set.weight, format: .number)
				.focused($focusedField, equals: .weightField)
				.keyboardType(.decimalPad)
				.frame(width: 64)
				.textFieldStyle(.roundedBorder)
				.multilineTextAlignment(.center)
			
			// Remove Button
			Spacer()
			if isDeleteEnabled {
                withAnimation {
                    Button {
                        focusedField = nil
                        isEnabled = false
                        
                        withAnimation {
                            action(set.id)
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color(UIColor.red))
                    }
                    .allowsHitTesting(isEnabled)
                }
			}
		}
	}
}

struct SetView_Previews: PreviewProvider {
	@State static var setModel: SetModel = SetModel(setIndex: 10)

    static var previews: some View {
        SetView(isDeleteEnabled: true, set: $setModel) {_ in }
    }
}
