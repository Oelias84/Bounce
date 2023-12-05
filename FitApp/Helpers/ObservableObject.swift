//
//  ObservableObject.swift
//  FitApp
//
//  Created by Ofir Elias on 15/07/2022.
//

import Foundation

final class ProjectObservableObject<T> {
	
	var value: T {
		didSet {
			listener?(value)
		}
	}
	
	private var listener: ((T)->())?
	
	init(_ value: T) {
		self.value = value
	}
	
	func bind(_ listener: @escaping (T)->()) {
		listener(value)
		self.listener = listener
	}
}
