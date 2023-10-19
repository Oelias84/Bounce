//
//  ExerciseListView.swift
//  FitApp
//
//  Created by Ofir Elias on 25/11/2022.
//

import SwiftUI

struct ExerciseListView: View {
    
    @ObservedObject var viewModel: ExerciseListViewModel
    
    @FocusState var focusedField: SetView.Field?
    
    let selectedExercise: (Int)->()
    let endEditing: ()->()
    
    @State private var isShowingExerciseOptions = false
        
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(0..<viewModel.getExercisesCount, id: \.self) { index in
                let workoutExercise = viewModel.getWorkoutExercise(at: index)
                
                VStack {
                    ExerciseDropViewContainer(viewModel: ExerciseDropViewModel(index: index, workoutExercise: workoutExercise), focusedField: _focusedField) {
                        exerciseIndex in
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
            // Keyboard confirm Buttonma
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("אישור") {
                    if focusedField == .repeatsField {
                        focusedField = .weightField
                    } else {
                        focusedField = nil
                        endEditing()
                        WorkoutManager.shared.updateExercisesStates()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingExerciseOptions) {
            Capsule(style: .continuous)
                .fill(Color(uiColor: .projectTail))
                .frame(width: 60, height: 3)
                .padding()
            
            ExerciseOptionsListSheetView(viewModel: ExerciseOptionsListSheetViewModel(exerciseType: viewModel.getSelectedExerciseType, workoutIndex: viewModel.getWorkoutIndex)) { selectedExerciseOption in
                viewModel.replaceExercise(with: selectedExerciseOption)
                isShowingExerciseOptions.toggle()
            }
        }
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    
    static var previews: some View {
        ExerciseListView(viewModel: ExerciseListViewModel(workoutIndex: 0)) { index in
            return
        } endEditing: {
            return
        }
    }
}
