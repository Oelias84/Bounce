//
//  ExerciseListView.swift
//  FitApp
//
//  Created by Ofir Elias on 25/11/2022.
//

import SwiftUI

struct ExerciseListView: View {
	
	@StateObject var viewModel: ExerciseListViewModel
	@FocusState var focusedField: SetView.Field?
	
	let selectedExercise: (Int)->()
	let endEditing: ()->()
	
	@State private var isShowingExerciseOptions = false

	var body: some View {
        ScrollView(showsIndicators: false) {
			ForEach(0..<viewModel.getExercisesCount, id: \.self) { index in
				let workoutExercise = viewModel.getWorkoutExercise(at: index)
                let exerciseState = $viewModel.exercisesState.first(where: {$0.exerciseNumber.wrappedValue == workoutExercise.exerciseToPresent!.exerciseNumber ?? 0})!
                    
                
                    VStack {
                        ExerciseDropViewContainer(viewModel: ExerciseDropViewModel(index: index, workoutExercise: workoutExercise),
                                                  exerciseState: exerciseState, focusedField: _focusedField) { exerciseIndex in
                            // Call back for moving into the exercise detail
                            selectedExercise(exerciseIndex)
                        } replacerButtonAction: { exerciseNumberToReplace in
                            viewModel.exerciseNumberToReplace = exerciseNumberToReplace
                            isShowingExerciseOptions.toggle()
                        }
                        .padding(.horizontal)
                    }
			}
		}
		.background(Color(UIColor.projectBackgroundColor))
		.toolbar {
			// Keyboard confirm Button
			ToolbarItemGroup(placement: .keyboard) {
				Spacer()
				Button("אישור") {
					if focusedField == .repeatsField {
						focusedField = .weightField
					} else {
						focusedField = nil
						endEditing()
					}
				}
			}
		}
		.sheet(isPresented: $isShowingExerciseOptions) {
			ExerciseOptionsListSheetView(viewModel: ExerciseOptionsListSheetViewModel(exerciseType: viewModel.getSelectedExerciseType, workoutIndex: viewModel.getWorkoutIndex)) { selectedExerciseOption in
				viewModel.replaceExercise(with: selectedExerciseOption)
				isShowingExerciseOptions.toggle()
			}
		}
	}
}

struct ExerciseListView_Previews: PreviewProvider {
	
	static var previews: some View {
		let exercise = Exercise(name: "Upper", videos: ["gs://my-fit-app-a8595.appspot.com/42"], title: "רגליים", text: "", maleText: "", type: "legs", exerciseNumber: 0)
		let workExercise = WorkoutExercise(exercise: "1", repeats: "15-20", sets: "4", exerciseToPresent: exercise)
		let workout = Workout(exercises: [workExercise], name: "", time: "", type: 1)
		
		ExerciseListView(viewModel: ExerciseListViewModel(workoutIndex: 0)) { index in
			return
		} endEditing: {
			return
		}
	}
}
