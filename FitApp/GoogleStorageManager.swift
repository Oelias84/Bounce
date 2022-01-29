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
	
	public func uploadImage(data: Data, fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
		storage.child(fileName).putData(data, metadata: nil) { metadata, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			completion(.success(()))
		}
	}
	public func uploadVideo(fileUrl: URL, fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
		
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
