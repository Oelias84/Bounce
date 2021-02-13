//
//  GoogleStorageManager.swift
//  FitApp
//
//  Created by Ofir Elias on 07/02/2021.
//

import Foundation
import FirebaseStorage



final class GoogleStorageManager {
	
	static let shared = GoogleStorageManager()
	private let storage = Storage.storage().reference()
	
	public typealias UploadPictureCompletion = (Result<String, Error>) -> Void

	enum ChildType: CustomStringConvertible {
		
		case profileImage
		case weightImage
		case messagesImage
		
		var description : String {
		  switch self {
		  case .profileImage: return "images"
		  case .weightImage: return "weight"
		  case .messagesImage: return "message_images"
		  }
		}
	}
	
	public func uploadImage(from child: ChildType, data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
		
		storage.child("\(child)/\(fileName)").putData(data, metadata: nil) { metadata, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			self.storage.child("\(child)/\(fileName)").downloadURL { url, error in
				if let error = error {
					completion(.failure(error))
					return
				}
				
				let urlString = url!.absoluteString
				print("download url returned: \(urlString)")
				completion(.success(urlString))
			}
		}
	}
	public func downloadImageURL(from child: ChildType, path: String, completion: @escaping (Result<URL, Error>) -> Void ) {
	self.storage.child("\(child)/\(path)").downloadURL { url, error in
		guard error == nil, let url = url else {
			completion(.failure(error!))
			return
		}
		
		print("download url returned: \(url)")
		completion(.success(url))
	}
}
}
