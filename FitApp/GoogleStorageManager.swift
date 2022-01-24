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
	
	public func uploadImage(from child: ChildType = .messagesImage, data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
		storage.child("\(child.description)/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			self?.storage.child("\(child.description)/\(fileName)").downloadURL { url, error in
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
	public func uploadVideo(child: ChildType = .messagesVideos, fileUrl: URL, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
		storage.child("\(child.description)/\(fileName)").putFile(from: fileUrl, metadata: nil) { [weak self] metadata, error in
			if let error = error {
				print(error.localizedDescription)
				completion(.failure(error))
				return
			}
			
			self?.downloadImageURL(from: child, path: fileName, completion: {
				result in
				
				switch result {
					
				case .success(let url):
					
					let urlString = url.absoluteString
					print("download url returned: \(urlString)")
					completion(.success(urlString))
				case .failure(let error):
					
					print("Error:", error.localizedDescription)
				}
				if let error = error {
					completion(.failure(error))
					return
				}
			})
		}
	}
	public func downloadImageURL(from child: ChildType, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
		storage.child("\(child.description)/\(path)").downloadURL { url, error in
			guard error == nil, let url = url else {
				completion(.failure(error!))
				return
			}
			
			print("download url returned: \(url)")
			completion(.success(url))
		}
	}
}
