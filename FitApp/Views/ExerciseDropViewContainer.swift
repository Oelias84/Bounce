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
    @State var isSetViewLock: Bool = false
    
    @FocusState var focusedField: SetView.Field?
    
    let action: (Int)->()
    let replacerButtonAction: (Int)->Void
    var body: some View {
        VStack(alignment: .leading) {
            //MARK: - Exercise view
            ExerciseView(index: viewModel.getIndex, name: viewModel.getName, type: viewModel.getType, exerciseNumber: viewModel.exerciseNumber, numberOfSetes: viewModel.getNumberOfSets,
                         numberOfRepeats: viewModel.getNumberOfRepeats, presentedNumber: viewModel.getExercisePresentNumber, showDetails: $showDetails, action: action) { exerciseToReplace in
                // Replce exercise clicked
                showDetails = false
                replacerButtonAction(exerciseToReplace)
            } dropDownAction: {
                // Open sets infomatio clicked
                showDetails.toggle()
                // Adding first set
                if viewModel.exerciseState.setsState.count == 0 && showDetails {
                    // Add First Set if dose not exist
                    let newSet = SetModel(setIndex: 0)
                    $viewModel.exerciseState.setsState.wrappedValue.append(newSet)
                    // Update Server
                    WorkoutManager.shared.updateExercisesStates()
                }
            }
            
            //MARK: - Dropdown View
            if showDetails {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    
                    ForEach($viewModel.exerciseState.setsState) { setsState in
                        let deleteEnable = setsState.setIndex.wrappedValue == viewModel.exerciseState.setsState.count-1

                        SetView(isDeleteEnabled: deleteEnable, set: setsState, id: setsState.id, focusedField: _focusedField) { id in
                            
                            // Toggle show details button if last set deleted
                            if viewModel.exerciseState.setsState.count == 1 {
                                withAnimation {
                                    showDetails.toggle()
                                }
                            }
                            
                            // Remove if find
                            if let index = $viewModel.exerciseState.setsState.wrappedValue.firstIndex(where: {$0.id == id}) {
                                $viewModel.exerciseState.setsState.wrappedValue.remove(at: index)
                            }
                            // Update Server
                            WorkoutManager.shared.updateExercisesStates()
                        }
                        
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: showDetails ? .infinity : .none)
                .clipped()
                
                //MARK: - Add Set Button
                HStack {
                    withAnimation {
                        Button {
                            // Add Set
                            let newSet = SetModel(setIndex: viewModel.exerciseState.setsState.count)
                            withAnimation {
                                $viewModel.exerciseState.setsState.wrappedValue.append(newSet)
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color(UIColor.projectTail))
                        }
                        .padding(2)
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
}

struct ExerciseDropView_Previews: PreviewProvider {
    
    @State static var exerciseState: ExerciseState = ExerciseState(exerciseNumber: 0)
    @State static var exercise: WorkoutExercise = WorkoutExercise(exercise: "1", repeats: "12", sets: "12", exerciseToPresent: nil)
    
    static var previews: some View {
        ExerciseDropViewContainer(viewModel: ExerciseDropViewModel(index: 1, workoutExercise: exercise)) { _ in
            
        } replacerButtonAction: { _ in
            
        }
    }
}
