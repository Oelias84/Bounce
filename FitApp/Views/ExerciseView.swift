//
//  SwiftUIView.swift
//  FitApp
//
//  Created by Ofir Elias on 27/02/2023.
//

import SwiftUI

struct ExerciseView: View {
	
	@ObservedObject var viewModel: ExerciseViewModel
	
	@Binding var showDetails: Bool
	
	let action: (Int)->Void
	let dropDownAction: ()->Void
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack(alignment: .top) {
				VStack(alignment: .leading) {
					Text("תרגיל \(viewModel.getExercisePresentNumber)#")
						.font(Font.custom(K.Fonts.regularText, size: 14))
					Text(viewModel.getName)
						.font(Font.custom(K.Fonts.boldText, size: 22))
				}
				.padding(.bottom, 8)
				
				// Tag View
				Spacer()
				exerciseTag
			}
			
			HStack(alignment: .center) {
				// Drop down button
				Button {
					withAnimation {
						dropDownAction()
					}
				} label: {
					Image(systemName: "chevron.down.circle.fill")
						.resizable()
						.frame(width: 24, height: 24)
						.rotationEffect(.degrees(showDetails ? -180 : 0))
						.foregroundColor(Color(UIColor.projectGreen))
				}
				.padding(.trailing, 10)
				
				// Exercise details
				Text("סטים: X\(viewModel.getNumberOfSets)")
					.font(Font.custom(K.Fonts.regularText, size: 16))
					.padding(.trailing, 16)
				Text("חזרות: X\(viewModel.getNumberOfRepeats)")
					.font(Font.custom(K.Fonts.regularText, size: 16))
				
				// Explain Button (continue to exercise screen)
				Spacer()
				Button {
					action(viewModel.getIndex)
				} label: {
					Text("הסבר")
						.font(Font.custom(K.Fonts.regularText, size: 14))
						.foregroundColor(Color(UIColor.projectTail))
						.padding(.trailing, -4)
					Image(systemName: "chevron.forward.circle.fill")
						.resizable()
						.frame(width: 24, height: 24)
						.foregroundColor(Color(UIColor.projectTail))
				}
			}
		}
	}
	
	// Tag View
	var exerciseTag: some View {
		VStack {
			Text(viewModel.getTag.0)
				.foregroundColor(.white)
				.font(Font.custom(K.Fonts.boldText, size: 12))
		}
		.frame(width: 54, height: 24)
		.background(Color(viewModel.getTag.1))
		.cornerRadius(12)
	}
}

struct ExerciseView_Previews: PreviewProvider {
	@State static var exercisesState = WorkoutExercise(exercise: "1", repeats: "12", sets: "12", exerciseToPresent: nil)
	@State static var showDetails: Bool = false

	static var previews: some View {
		
		ExerciseView(viewModel: ExerciseViewModel(index: 0, exercise: $exercisesState), showDetails: $showDetails) { _ in
			
		} dropDownAction: {
			
		}
	}
}
