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
		guard let stringsDictionary = loadStaticStrings() else { return nil }
		
		if let userGender = UserProfile.defaults.getGender {

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
		} else {
			for string in stringsDictionary {
				if let strKey = string.key {
					if let keyNumber = Int(strKey) {
						genderString[keyNumber] = string.male
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
//				print("Could't fetch static Text from server: \n\(error)")
			}
		}
		return readLocalFile()
	}
	private func readLocalFile() -> [StringItem]? {
		do {
			if let bundlePath = Bundle.main.path(forResource: "StaticText", ofType: "json"),
				let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
				let decoder = JSONDecoder()
				let jsonDecoderData = try decoder.decode(StaticString.self, from: jsonData)
				return jsonDecoderData.dictionary
			}
		} catch {
//			print("Could't fetch static data Text local file: \n\(error)")
		}
		return nil
	}
}
