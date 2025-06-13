//
//  ChatMessage.swift
//  ChatUIKitFramework
//
//  Created by Aura on 13/06/25.
//

import UIKit

public struct ChatMessage {
    let text: String
    let isUser: Bool
    
    public init(text: String, isUser: Bool) {
        self.text = text
        self.isUser = isUser
    }
}
