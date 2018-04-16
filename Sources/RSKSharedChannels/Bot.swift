//
// Bot.swift
//
// Copyright © 2018 R.SK Lab, https://rsk-lab.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import SlackKit

internal protocol BotDelegate {
    
    func bot(_ bot: Bot, didHandleMessage message: Message)
}

internal class Bot: Equatable {
    
    // MARK: - Internal Properties
    
    internal let apiTokenString: String
    
    internal var authenticatedUser: User? {
        
        return self.client?.authenticatedUser
    }
    
    internal var bots: [SKCore.Bot] {
        
        guard let values = self.client?.bots.values else {
            
            return []
        }
        return Array(values)
    }
    
    internal var channels: [Channel] {
        
        guard let values = self.client?.channels.values else {
            
            return []
        }
        return Array(values)
    }
    
    internal var delegate: BotDelegate?
    
    internal var primaryOwner: User? {
        
        return self.users.first(where: { (user) -> Bool in
            
            return user.isPrimaryOwner == true
        })
    }
    
    internal var team: Team? {
        
        return self.client?.team
    }
    
    internal var users: [User] {
        
        guard let values = self.client?.users.values else {
            
            return []
        }
        return Array(values)
    }
    
    // MARK: - Private Properties
    
    private var client: Client? {
        
        return self.clientConnection?.client
    }
    
    private let clientConnection: ClientConnection?
    
    // MARK: - Lifecycle
    
    internal init(apiTokenString: String, slackKit: SlackKit) {
        
        self.apiTokenString = apiTokenString
        
        slackKit.addRTMBotWithAPIToken(apiTokenString)
        slackKit.addWebAPIAccessWithToken(apiTokenString)
        
        self.clientConnection = slackKit.clients[self.apiTokenString]
        
        slackKit.notificationForEvent(.message, event: { [weak self] (event, clientConnection) in

            guard let strongSelf = self, let authenticatedUser = clientConnection?.client?.authenticatedUser, authenticatedUser.id == strongSelf.client?.authenticatedUser?.id, let message = event.message, message.user != authenticatedUser.id else {

                return
            }
            strongSelf.delegate?.bot(strongSelf, didHandleMessage: message)
        })
    }
    
    // MARK: - Internal API
    
    internal func sendMessage(withText text: String = "", toChannelWithName channelName: String, attachments: [Attachment]? = nil, onSuccess successBlock: (() -> ())? = nil, onFailure failureBlock: @escaping ((Error) -> ())) {
        
        guard let webAPI = self.clientConnection?.webAPI, let authenticatedUserName = self.authenticatedUser?.name else {
            
            return
        }
        webAPI.sendMessage(channel: channelName, text: text, username: authenticatedUserName, asUser: true, parse: .none, attachments: attachments, success: { (_) in
            
            successBlock?()
            
        }, failure: failureBlock)
    }
    
    // MARK: - Equatable
    
    internal static func ==(lhs: Bot, rhs: Bot) -> Bool {
        
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
