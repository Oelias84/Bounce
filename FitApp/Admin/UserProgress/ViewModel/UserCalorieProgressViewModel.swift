//
//  UserCalorieProgressViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 06/06/2022.
//

import Foundation

final class UserCalorieProgressViewModel {
	
	var userID: String!
	var userProgress: ObservableObject<[String: CaloriesProgressState]?> = ObservableObject(nil)
	
	init(userID: String) {
		self.userID = userID
		
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchCaloriesProgress()
		}
	}
	
	//Getter
	var getProgressCount: Int {
		return userProgress.value?.count ?? 0
	}
	func getTitle(at row: Int) -> String {
		return Array(userProgress.value!.keys)[row]
	}
	func getProgressData(at row: Int) -> CaloriesProgressState {
		return Array(userProgress.value!.values)[row]
	}
}

extension UserCalorieProgressViewModel {
	
	private func fetchCaloriesProgress() {
		GoogleApiManager.shared.getUserCaloriesProgressData(userID: userID) {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let data):
				guard let data = data else { return }
				
				self.userProgress.value = data
			case .failure(let error):
				print("Error:", error.localizedDescription)
			}
		}
	}
}
