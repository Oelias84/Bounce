//
//  Static.swift
//  FitApp
//
//  Created by Ofir Elias on 09/01/2022.
//

import Foundation

public struct StaticString: Codable {
	
	var dictionary: [StringItem]
}

public struct StringItem: Codable {
	
	var key: String?
	var male: String?
	var female: String?
}
