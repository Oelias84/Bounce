//
//  SwiftUIView.swift
//  FitApp
//
//  Created by Ofir Elias on 27/02/2023.
//

import SwiftUI

struct ExerciseView: View {
    
    var index: Int
    var name: String
    var type: String
    var exerciseNumber: Int?
    var numberOfSetes: String
    var numberOfRepeats: String
    var presentedNumber: String
    
    @Binding var showDetails: Bool
    
    let action: (Int)->Void
    let replacerButtonAction: (_ exerciseToReplace: Int)->Void
    let dropDownAction: ()->Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                
                //MARK: - Title Text
                VStack(alignment: .leading) {
                    HStack {
                        Text("תרגיל \(presentedNumber)#")
                            .font(Font.custom(K.Fonts.regularText, size: 14))
                        
                        //MARK: - Tag View
                        exerciseTag
                    }
                    Text(name)
                        .font(Font.custom(K.Fonts.boldText, size: 18))
                }
                .padding(.bottom, 8)
                
                Spacer()
                
                //MARK: - Exercise Options Button
                let exerciseType = ExerciseType(rawValue: type)
                
                if !(exerciseType == .full_warmup || exerciseType == .lower_warmup || exerciseType == .upper_warmup) {
                    Button {
                        guard let exerciseNumber else { return }
                        replacerButtonAction(exerciseNumber)
                    } label: {
                        Image(systemName: "arrow.2.squarepath")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(UIColor.projectGreen))
                    }
                }
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
                
                HStack(spacing: 16) {
                    // Exercise details
                    Text("סטים: X\(numberOfSetes)")
                        .font(Font.custom(K.Fonts.regularText, size: 16))
                    
                    Text("חזרות: \(numberOfRepeats)")
                        .font(Font.custom(K.Fonts.regularText, size: 16))
                    Spacer()
                }
                
                // Explain Button (continue to exercise screen)
                Button {
                    action(index)
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
            Text(getTag.0)
                .foregroundColor(.white)
                .font(Font.custom(K.Fonts.boldText, size: 12))
                .padding(.horizontal)
        }
        .frame(height: 24)
        .background(Color(getTag.1))
        .cornerRadius(12)
    }
    var getTag: (String, UIColor) {
        switch type {
        case "glutes":
            return ("Glutes", #colorLiteral(red: 0.3882352941, green: 0.6392156863, blue: 0.2941176471, alpha: 1))
        case "quad":
            return ("Quad", #colorLiteral(red: 0.3882352941, green: 0.6392156863, blue: 0.2941176471, alpha: 1))
        case "hamstring":
            return ("Hamstring", #colorLiteral(red: 0.3882352941, green: 0.6392156863, blue: 0.2941176471, alpha: 1))
        case "legs":
            return ("רגליים", #colorLiteral(red: 0.3882352941, green: 0.6392156863, blue: 0.2941176471, alpha: 1))
        case "chest":
            return ("Chest", #colorLiteral(red: 0.1863320172, green: 0.6013119817, blue: 0.9211298823, alpha: 1))
        case "back":
            return ("Back", #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        case "shoulders":
            return ("Shoulders", #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))
        case "stomach":
            return ("בטן", #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1))
        case "abs":
            return ("Abs", #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1))
        case "full_warmup":
            return ("Full Warmup", .lightGray)
        case "lower_warmup":
            return ("Lower Warmup", .lightGray)
        case "upper_warmup":
            return ("Upper Warmup", .lightGray)
        default:
            return ("", UIColor.white)
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    @State static var exercisesState = WorkoutExercise(exercise: "1", repeats: "12", sets: "12", exerciseToPresent: nil)
    @State static var showDetails: Bool = false
    
    static var previews: some View {
        
        ExerciseView(index: 0, name: "PushUps", type: "legs", numberOfSetes: "4", numberOfRepeats: "5-12", presentedNumber: "0", showDetails: $showDetails) { _ in
            
        } replacerButtonAction: { _ in
            
        } dropDownAction: {
            
        }
    }
}
