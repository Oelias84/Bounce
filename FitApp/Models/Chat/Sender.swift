//
//  Sender.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import Foundation
import MessageKit

struct Sender: SenderType {
	public var photoURL: String
	public var senderId: String
	public var displayName: String
}

struct Media: MediaItem {
	
	var url: URL?
	var image: UIImage?
	var mediaURLString: String?
	var previewBitmap: UIImage?
	var placeholderImage: UIImage
	var size: CGSize
}
