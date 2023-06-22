//
//  ExerciseOptionsView.swift
//  FitApp
//
//  Created by Ofir Elias on 06/03/2023.
//

import SwiftUI

struct ExerciseOptionsView: View {
	
	@State var exercise: Exercise
	
	let changeExerciseAction: (Exercise)->Void
	
	var body: some View {
        HStack(alignment: .top) {
			Button {
				changeExerciseAction(exercise)
			} label: {
                Spacer()
                
				VStack {
					Text(exercise.name)
						.multilineTextAlignment(.trailing)
						.colorMultiply(.black)
						.font(Font.custom(K.Fonts.boldText, size: 22))
                        .padding()
                    Spacer()
				}
			}
            .frame(width: .infinity, height: 100)
		}
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: Color(UIColor.lightGray.withAlphaComponent(0.2)), radius: 6, y: 4)
	}
}

struct ExerciseOptionsView_Previews: PreviewProvider {
	static var exercise = Exercise(name: "Hip Thrust (b-stance) Hip Thrust (b-stance)", videos: [""], title: "", text: "", maleText: "", type: "legs", exerciseNumber: 0)
	
	static var previews: some View {
		ExerciseOptionsView(exercise: exercise) { _ in
			
		}
	}
}
