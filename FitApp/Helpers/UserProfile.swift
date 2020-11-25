//
//  UserProfile.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import Foundation

struct UserProfile {
	
	private let standard = UserDefaults.standard
	static var shared = UserProfile()
	
	var id: String?{
		didSet{
			standard.set(id, forKey: K.User.id)
		}
	}
	var name: String?{
		didSet{
			standard.set(name, forKey: K.User.name)
		}
	}
}
