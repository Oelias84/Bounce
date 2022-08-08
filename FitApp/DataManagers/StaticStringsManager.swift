//
//  StaticStringsManager.swift
//  FitApp
//
//  Created by Ofir Elias on 09/01/2022.
//

import Foundation

struct StaticStringsManager {
	
	static let shared = StaticStringsManager()
	
	var getGenderString: Dictionary<Int, String>? {
		return parsedGenderString()
	}
	
	func parsedGenderString() -> Dictionary<Int, String>? {
		var genderString = Dictionary<Int, String>()
		guard let stringsDictionary = loadStaticStrings(), let userGender = UserProfile.defaults.getGender else { return nil }
		
		switch userGender {
		case .male:
			for string in stringsDictionary {
				if let strKey = string.key {
					if let keyNumber = Int(strKey) {
						genderString[keyNumber] = string.male
					}
				}
			}
		case .female:
			for string in stringsDictionary {
				if let strKey = string.key {
					if let keyNumber = Int(strKey) {
						genderString[keyNumber] = string.female
					}
				}
			}
		}
		return genderString
	}
	private func loadStaticStrings() -> [StringItem]? {
		
		if let url = Bundle.main.url(forResource: nil, withExtension: "json") {
			do {
				let data = try Data(contentsOf: url)
				let decoder = JSONDecoder()
				let jsonData = try decoder.decode(StaticString.self, from: data)
				return jsonData.dictionary
			} catch {
				print("error:\(error)")
			}
		}
		return nil
		
	}
	private func readLocalFile() -> Data? {
		do {
			if let bundlePath = Bundle.main.path(forResource: "StaticText.json",
												 ofType: "json"),
				let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
				return jsonData
			}
		} catch {
			print(error)
		}
		
		return nil
	}
}
