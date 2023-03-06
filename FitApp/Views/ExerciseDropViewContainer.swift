//
//  ExerciseDropView.swift
//  FitApp
//
//  Created by Ofir Elias on 20/02/2023.
//

import SwiftUI


struct ExerciseDropViewContainer: View {
	
	@ObservedObject var viewModel: ExerciseDropViewModel
	
	@State var showDetails: Bool = false
	@Binding var exerciseState: ExerciseState
	@FocusState var focusedField: SetView.Field?
	
	let action: (Int)->()
	
	var body: some View {
		VStack(alignment: .leading) {
			//MARK: - Exercise view
			ExerciseView(index: viewModel.getIndex(), name: viewModel.getName(), type: viewModel.getType(), numberOfSetes: viewModel.getNumberOfSets(),
						 numberOfRepeats: viewModel.getNumberOfRepeats(), presentedNumber: viewModel.getNumberOfRepeats(), showDetails: $showDetails, action: action) {
				
				showDetails.toggle()
				
				// Adding first set
				if $exerciseState.setsState.count == 0 && showDetails {
					exerciseState.setsState.append(SetModel(setIndex: 0))
				}
			}
			
			//MARK: - Dropdown View
			if showDetails {
				Divider()
				LazyVStack(alignment: .leading, spacing: 8) {
					ForEach(0..<$exerciseState.setsState.count, id: \.self) { index in
						let setsState = $exerciseState.setsState[index]
						let deleteEnable = setsState.setIndex.wrappedValue == $exerciseState.setsState.count-1
						
						SetView(isDeleteEnabled: deleteEnable, set: setsState, focusedField: _focusedField) { id in
							withAnimation {
								// Toggle show details button if last set deleted
								if exerciseState.setsState.count == 1 { showDetails.toggle() }
								// Remove if find
								$exerciseState.setsState.wrappedValue.removeAll(where: {$0.id == id})
							}
						}
					}
				}
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: showDetails ? .infinity : .none)
				.clipped()
				
				//MARK: - Add Set Button
				HStack {
					Button {
						withAnimation {
							$exerciseState.setsState.wrappedValue.append(SetModel(setIndex: exerciseState.setsState.count))
							focusedField = .repeatsField
						}
					} label: {
						Image(systemName: "plus.circle")
							.frame(width: 16, height: 16)
							.foregroundColor(Color(UIColor.projectTail))
					}
					.padding(2)
					Spacer()
				}
			}
		}
		.padding()
		.background(Color.white)
		.cornerRadius(12)
		.padding(4)
		.shadow(color: Color(UIColor.lightGray.withAlphaComponent(0.2)), radius: 6, y: 4)
	}
}

struct ExerciseDropView_Previews: PreviewProvider {

	@State static var exerciseState: ExerciseState = ExerciseState(index: 0)
	@State static var exercise: WorkoutExercise = WorkoutExercise(exercise: "1", repeats: "12", sets: "12", exerciseToPresent: nil)
	
	static var previews: some View {
		ExerciseDropViewContainer(viewModel: ExerciseDropViewModel(index: 1, workoutExercise: exercise), exerciseState: $exerciseState) { _ in

		}
	}
}
