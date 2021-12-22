//
//  ExpandableSectionData.swift
//  FitApp
//
//  Created by Ofir Elias on 20/12/2021.
//

import Foundation

struct ExpandableSectionData {
	
	var name: String
	var text: [String]
	var collapsed: Bool
	
	init(name: String, text: [String], collapsed: Bool = true) {
		self.name = name
		self.text = text
		self.collapsed = collapsed
	}
}
