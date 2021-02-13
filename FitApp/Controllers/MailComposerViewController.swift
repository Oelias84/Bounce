//
//  MailComposerViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import Foundation
import MessageUI
import FirebaseAuth

class MailComposerViewController: MFMailComposeViewController {
	
	init(recipients: [String]?, subject: String = "", messageBody: String = "", messageBodyIsHtml: Bool = false) {
		super.init(nibName: nil, bundle: nil)
		setToRecipients(recipients)
		setSubject(subject)
		if let email = Auth.auth().currentUser?.email {
			setPreferredSendingEmailAddress(email)
		}
		setMessageBody(messageBody, isHTML: messageBodyIsHtml)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
