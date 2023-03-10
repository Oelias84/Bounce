//
//  ExerciseListView.swift
//  FitApp
//
//  Created by Ofir Elias on 25/11/2022.
//

import SwiftUI

struct ExerciseListView: View {
	
	@StateObject var exerciseListViewModel: ExerciseListViewModel
	@FocusState var focusedField: SetView.Field?
	
	let selectedExercise: (Int)->()
	let endEditing: ()->()
	
	@State private var isShowingExerciseOptions = false

	var body: some View {
		ScrollView {
			ForEach(0..<exerciseListViewModel.getExercisesCount, id: \.self) { index in
				let workoutExercise = exerciseListViewModel.getWorkoutExercise(at: index)
				let exerciseState = exerciseListViewModel.exercisesState.first(where: {$0.exerciseNumber == Int(workoutExercise.exercise)}) ?? ExerciseState(exerciseNumber: Int(workoutExercise.exercise)!)
				
				VStack {
					ExerciseDropViewContainer(viewModel: ExerciseDropViewModel(index: index, workoutExercise: workoutExercise),
											  exerciseState: exerciseState, focusedField: _focusedField) { exerciseIndex in
						// Call back for moving into the exercise detail
						selectedExercise(exerciseIndex)
					} replacerButtonAction: { exerciseNumberToReplace in
						exerciseListViewModel.exerciseNumberToReplace = exerciseNumberToReplace
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
			ExerciseOptionsListSheetView(viewModel: ExerciseOptionsListSheetViewModel(exerciseType: exerciseListViewModel.getSelectedExerciseType, workoutIndex: exerciseListViewModel.getWorkoutIndex)) { selectedExerciseOption in
				exerciseListViewModel.replaceExercise(with: selectedExerciseOption)
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
		
		ExerciseListView(exerciseListViewModel: ExerciseListViewModel(workoutIndex: 0, workout: workout)) { index in
			return
		} endEditing: {
			return
		}
	}
}
