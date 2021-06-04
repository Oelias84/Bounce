//
//  Notification.swift
//  FitApp
//
//  Created by Ofir Elias on 03/06/2021.
//

import Foundation

struct Notification {
	
	var id = UUID().uuidString
	var title: String
	var body: String
	var dateTime: DateComponents
}
