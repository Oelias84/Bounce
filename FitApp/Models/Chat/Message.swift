//
//  Message.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import Foundation
import MessageKit

struct Message: MessageType, Comparable {
	
	var sender: SenderType
	var messageId: String
	var sentDate: Date
	var kind: MessageKind
	var isIncoming: Bool
	var content: Any?
	var isPending: Bool = false
	
	static func < (lhs: Message, rhs: Message) -> Bool {
		return lhs.sentDate < rhs.sentDate
	}
	static func == (lhs: Message, rhs: Message) -> Bool {
		false
	}
}
