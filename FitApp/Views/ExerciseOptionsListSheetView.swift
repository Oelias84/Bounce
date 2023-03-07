//
//  ExerciseOptionsListSheetView.swift
//  FitApp
//
//  Created by Ofir Elias on 07/03/2023.
//

import SwiftUI

struct ExerciseOptionsListSheetView: View {
	
	@ObservedObject var viewModel: ExerciseOptionsListSheetViewModel
	
	var body: some View {
		VStack{
			ScrollView(showsIndicators: false) {
				ForEach(0..<viewModel.getExerciseOptionCount, id: \.self) { index in
					let exercise = viewModel.getExerciseOptions(at: index)
					
					ExerciseOptionsView(exercise: exercise) { exerciseNumber in
						
					}
					.padding(.horizontal)
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding()
		}
		.background(Color(UIColor.projectBackgroundColor))
	}
}

struct ExercisePotionsView_Previews: PreviewProvider {
	static var previews: some View {
		ExerciseOptionsListSheetView(viewModel: ExerciseOptionsListSheetViewModel(exerciseType: .chest, workoutIndex: 0))
	}
}
