//
//  Sender.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import Foundation
import MessageKit

struct Sender: SenderType {
	
	var senderId: String
	var displayName: String
}

struct Media: MediaItem {
	
	var url: URL?
	var image: UIImage?
	var placeholderImage: UIImage
	var size: CGSize
}