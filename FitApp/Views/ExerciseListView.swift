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
				
				ExerciseDropView(viewModel: ExerciseViewModel(index: index, exercise: exercise), exerciseState: exerciseState, focusedField: _focusedField) { exerciseIndex in
					// Call back for moving into the exercise detail
					selectedExercise(exerciseIndex)
				}
					.padding(.horizontal)
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

struct ExerciseDropView: View {
	
	@ObservedObject var viewModel: ExerciseViewModel
	@Binding var exerciseState: ExerciseState

	@FocusState var focusedField: SetView.Field?
	@State private var showDetails: Bool = false
	
	let action: (Int)->()
	
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
						showDetails.toggle()
						// Adding first set
						if $exerciseState.setsState.count == 0 && showDetails {
							exerciseState.setsState.append(SetModel(setIndex: 0))
						}
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
			
			// Sets list Dropdown View
			if showDetails {
				Divider()
				LazyVStack(alignment: .leading, spacing: 8) {
					ForEach(0..<$exerciseState.setsState.count, id: \.self) { index in
						let setsState = $exerciseState.setsState[index]
						let deleteEnable = setsState.setIndex.wrappedValue == $exerciseState.setsState.count-1
						
						SetView(isDeleteEnabled: deleteEnable, set: setsState, focusedField: _focusedField) { id in
							withAnimation {
								$exerciseState.setsState.wrappedValue.removeAll(where: {$0.id == id})
							}
						}
					}
				}
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: showDetails ? .infinity : .none)
				.clipped()
				
				// Add Set Button
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
		
		HStack {
			// Set Number
			Text("סט #\(set.setIndex+1)")
				.padding(.trailing, 10)
				.padding(.trailing, 0)
				.frame(width: 56)
				.font(Font.custom(K.Fonts.boldText, size: 16))
			
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
				Button {
					focusedField = nil
					isEnabled = false
					
					withAnimation {
						DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
							action(set.id)
							isEnabled = true
						}
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

struct ExerciseListView_Previews: PreviewProvider {
	
	static var previews: some View {
		let exercise = Exercise(name: "Upper", videos: ["gs://my-fit-app-a8595.appspot.com/42"], title: "רגליים", text: "", maleText: "", type: "legs")
		let workExercise = WorkoutExercise(exercise: "1", repeats: "15-20", sets: "4", exerciseToPresent: exercise)
		let workout = Workout(exercises: [workExercise], name: "", time: "", type: 1)
//		var exercisesState: Binding<[ExerciseState]> = [ExerciseState]()
//		ExerciseListView(viewModel: ExerciseListViewModel(workout: workout, exercisesState: $exercisesState)) { _ in } exerciseStateDate: { _ in }
	}
}
extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
