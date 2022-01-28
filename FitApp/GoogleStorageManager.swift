//
//  GoogleStorageManager.swift
//  FitApp
//
//  Created by Ofir Elias on 07/02/2021.
//

import Foundation
import FirebaseStorage

enum ChildType: CustomStringConvertible {
	
	case profileImage
	case weightImage
	case messagesImage
	case messagesVideos
	case pdf
	
	var description : String {
		switch self {
		case .profileImage:
			return "profile_image"
		case .weightImage:
			return "weight"
		case .pdf:
			return "pdf"
		case .messagesImage:
			return "messages_images"
		case .messagesVideos:
			return "messages_videos"
		}
	}
}

final class GoogleStorageManager {
	
	static let shared = GoogleStorageManager()
	private let storage = Storage.storage().reference()
	
	public func uploadImage(from child: ChildType = .messagesImage, data: Data, fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
		storage.child(fileName).putData(data, metadata: nil) { metadata, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			completion(.success(()))
		}
	}
	public func uploadVideo(child: ChildType = .messagesVideos, fileUrl: URL, fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
		
		storage.child(fileName).putFile(from: fileUrl, metadata: nil) {
			metadata, error in
			if let error = error {
				print(error.localizedDescription)
				completion(.failure(error))
				return
			}
			completion(.success(()))
		}
	}
	public func downloadURL(path: String, completion: @escaping (Result<URL, Error>) -> Void) {
		storage.child(path).downloadURL { url, error in
			guard error == nil, let url = url else {
				completion(.failure(error!))
				return
			}
			print("download url returned: \(url)")
			completion(.success(url))
		}
	}
}
