//
// DirectMessageMiddleware.swift
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
import SKServer

internal class DirectMessageMiddleware: Middleware {
    
    // MARK: - Internal Properties
    
    internal let fromWorkspaceBot: Bot
    
    internal let fromWorkspaceBotAttachmentColorString: String
    
    internal let tokenString: String
    
    internal let toWorkspaceBot: Bot
    
    internal let toWorkspaceBotAttachmentColorString: String
    
    // MARK: - Private Properties
    
    private let sendMessageOperationQueue: OperationQueue
    
    // MARK: - Lifecycle
    
    internal init(tokenString: String, fromWorkspaceBot: Bot, toWorkspaceBot: Bot, fromWorkspaceBotAttachmentColorString: String, toWorkspaceBotAttachmentColorString: String) {
        
        self.fromWorkspaceBot = fromWorkspaceBot
        self.fromWorkspaceBotAttachmentColorString = fromWorkspaceBotAttachmentColorString
        self.sendMessageOperationQueue = OperationQueue()
        self.tokenString = tokenString
        self.toWorkspaceBot = toWorkspaceBot
        self.toWorkspaceBotAttachmentColorString = toWorkspaceBotAttachmentColorString
    }
    
    // MARK: - Middleware
    
    internal func respond(to requestTuple: (RequestType, ResponseType)) -> (RequestType, ResponseType) {
        
        let request = requestTuple.0
        
        guard let webhookRequest = WebhookRequest(request: request), webhookRequest.token == self.tokenString, let webhookRequestText = webhookRequest.text, let webhookRequestUserName = webhookRequest.userName else {
            
            let response = Response(400)
            return (request, response)
        }
        
        guard let parameters = webhookRequestText.replacingOccurrences(of: "+", with: " ").removingPercentEncoding?.split(separator: " ", maxSplits: 2), parameters.count == 3, parameters.first == "dm" else {
            
            let response = Response(400)
            return (request, response)
        }
        
        // toChannelName
        
        let toChannelName = String(parameters[1])
        
        guard self.toWorkspaceBot.users.contains(where: { (user) -> Bool in
            
            guard let userName = user.name else {
                
                return false
            }
            return "@\(userName)" == toChannelName
            
        }) == true else {
            
            let response = Response(404)
            return (request, response)
        }
        
        // messageText
        
        let messageText = String(parameters[2])
        
        // authorName && authorIcon
        
        guard let authorName = webhookRequest.userName, let authorIcon = self.fromWorkspaceBot.users.first(where: { (user) -> Bool in
            
            return user.id == webhookRequest.userID
            
        })?.profile?.image24 else {
            
            let response = Response(500)
            return (request, response)
        }
        
        // attachments
        
        let attachmentDictionary = [
            
            "author_name": "\(authorName) sent you a DM",
            "author_icon": authorIcon,
            "color": self.toWorkspaceBotAttachmentColorString,
            "text": messageText
        ]
        
        let attachment = Attachment(attachment: attachmentDictionary)
        
        let attachments = [attachment]
        
        // backwardMessageToChannelName
        
        let backwardMessageToChannelName = "@\(webhookRequestUserName)"
        
        // backwardMessageToUserName
        
        let backwardMessageToUserName = toChannelName[toChannelName.index(toChannelName.startIndex, offsetBy: 1)..<toChannelName.endIndex]
        
        // attachments
        
        let backwardMessageAttachmentDictionary = [
            
            "author_name": "You sent a DM to \(backwardMessageToUserName)",
            "color": self.fromWorkspaceBotAttachmentColorString,
            "text": messageText
        ]
        
        let backwardMessageAttachment = Attachment(attachment: backwardMessageAttachmentDictionary)
        
        let backwardMessageAttachments = [backwardMessageAttachment]
        
        // Send messages
        
        self.toWorkspaceBot.sendMessage(toChannelWithName: toChannelName, attachments: attachments, onSuccess: { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.fromWorkspaceBot.sendMessage(toChannelWithName: backwardMessageToChannelName, attachments: backwardMessageAttachments, onFailure: { (error) in
                
                print("[Error]: \(error.localizedDescription)\n[Function]: \(#function)\n[Line]: \(#line)")
            })
            
        }, onFailure: { (error) in
            
            print("[Error]: \(error.localizedDescription)\n[Function]: \(#function)\n[Line]: \(#line)")
        })
        
        let response = Response(200)
        return (request, response)
    }
}
