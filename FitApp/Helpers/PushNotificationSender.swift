//
//  PushNotificationSender.swift
//  FitApp
//
//  Created by Ofir Elias on 05/05/2021.
//

import UIKit
import FirebaseAuth

class PushNotificationSender {
	
	func sendPushNotification(to token: String, title: String, body: String) {
		
		let key = K.User.serverKey
		guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else { return }
		
		let paramString: [String : Any] = [
			"to" : token,
			"notification" : ["title" : title,
							  "body" : body,
							  "sound" : "default"],
			"data" : ["id" : Auth.auth().currentUser?.uid ?? ""]
		]

		let urlRequest:URLRequest = {
			var request = URLRequest(url: url)
			
			request.httpMethod = "POST"
			request.setValue("key=\(key)", forHTTPHeaderField: "Authorization")
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [])
			return request
		}()
		
		let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
			data, response, error in
			
			guard let data = data, error == nil else {
				// check for fundamental networking error
				print("error=\(error!.localizedDescription)")
				return
			}

			if let httpStatus = response as? HTTPURLResponse {
				// check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(response!)")
			}

			guard let responseString = String(data: data, encoding: .utf8) else { return }
			print("responseString = \(responseString)")
		}
		task.resume()
	}
}
