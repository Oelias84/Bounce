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
	
	var body: some View {
		ScrollView {
			ForEach(0..<viewModel.getExercisesCount, id: \.self) { index in
				let exercise = $viewModel.workout.exercises[index]
				let exerciseState = $viewModel.exercisesState[index]
				
				HStack {
					ExerciseDropView(viewModel: ExerciseViewModel(index: index, exercise: exercise), exerciseState: exerciseState, focusedField: _focusedField) { exerciseIndex in
						// Call back for moving into the exercise detail
						selectedExercise(exerciseIndex)
					}
					.padding(.horizontal)}
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
	}
}

struct ExerciseListView_Previews: PreviewProvider {
	
	static var previews: some View {
		let exercise = Exercise(name: "Upper", videos: ["gs://my-fit-app-a8595.appspot.com/42"], title: "רגליים", text: "", maleText: "", type: "legs", exerciseNumber: 0)
		let workExercise = WorkoutExercise(exercise: "1", repeats: "15-20", sets: "4", exerciseToPresent: exercise)
		let workout = Workout(exercises: [workExercise], name: "", time: "", type: 1)
		let exerciseState = ExerciseState(index: 0)
		let exercisesState: [ExerciseState] = [exerciseState]
		
		ExerciseListView(viewModel: ExerciseListViewModel(workout: workout, exercisesState: exercisesState)) { index in
			return
		} endEditing: {
			return
		}
	}
}
