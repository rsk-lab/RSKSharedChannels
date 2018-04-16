//
// Router.swift
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

internal final class Router: BotDelegate {
    
    // MARK: - Private Properties
    
    private let slackKit: SlackKit
    
    private let xWorkspaceBot: Bot
    
    private let xWorkspaceBotAttachmentColorString: String
    
    private let yWorkspaceBot: Bot
    
    private let yWorkspaceBotAttachmentColorString: String
    
    // MARK: - Lifecycle
    
    internal init() {
        
        self.slackKit = SlackKit()
        self.xWorkspaceBot = Bot(apiTokenString: Environment.xWorkspaceBotAPITokenString, slackKit: self.slackKit)
        self.xWorkspaceBotAttachmentColorString = Environment.xWorkspaceBotAttachmentColorString
        self.yWorkspaceBot = Bot(apiTokenString: Environment.yWorkspaceBotAPITokenString, slackKit: self.slackKit)
        self.yWorkspaceBotAttachmentColorString = Environment.yWorkspaceBotAttachmentColorString
        
        let fromXWorkspaceBotToYWorkspaceBotDirectMessageMiddleware = DirectMessageMiddleware(tokenString: Environment.xWorkspaceSlashCommandTokenString, fromWorkspaceBot: self.xWorkspaceBot, toWorkspaceBot: self.yWorkspaceBot, fromWorkspaceBotAttachmentColorString: self.xWorkspaceBotAttachmentColorString, toWorkspaceBotAttachmentColorString: self.yWorkspaceBotAttachmentColorString)
        
        let xWorkspaceSlashCommandRequestRoute = RequestRoute(path: Environment.xWorkspaceSlashCommandPath, middleware: fromXWorkspaceBotToYWorkspaceBotDirectMessageMiddleware)
        
        let fromYWorkspaceBotToXWorkspaceBotDirectMessageMiddleware = DirectMessageMiddleware(tokenString: Environment.yWorkspaceSlashCommandTokenString, fromWorkspaceBot: self.yWorkspaceBot, toWorkspaceBot: self.xWorkspaceBot, fromWorkspaceBotAttachmentColorString: self.yWorkspaceBotAttachmentColorString, toWorkspaceBotAttachmentColorString: self.xWorkspaceBotAttachmentColorString)
        
        let yWorkspaceSlashCommandRequestRoute = RequestRoute(path: Environment.yWorkspaceSlashCommandPath, middleware: fromYWorkspaceBotToXWorkspaceBotDirectMessageMiddleware)
        
        let responder = SlackKitResponder(routes: [xWorkspaceSlashCommandRequestRoute, yWorkspaceSlashCommandRequestRoute])
        
        let server = SwifterServer(port: Environment.port, responder: responder)
        self.slackKit.addServer(server, responder: responder)
        
        self.xWorkspaceBot.delegate = self
        self.yWorkspaceBot.delegate = self
    }
    
    // MARK: - Private API
    
    private func replaceNonLinkedUserNamesAndLinkedUserIDsByLinkedUserNames(of users: [User], in string: String) -> String {
        
        var string = string
        users.forEach({ (user) in
            
            if let userName = user.name {
                
                var range = string.startIndex..<string.endIndex
                while let subrange = string.range(of: "<@" + userName + ">", range: range) {
                    
                    string.replaceSubrange(subrange, with: "@" + userName)
                    
                    guard subrange.upperBound != range.upperBound else {
                        
                        break
                    }
                    range = string.index(subrange.upperBound, offsetBy: 1)..<string.endIndex
                }
                
                range = string.startIndex..<string.endIndex
                while let subrange = string.range(of: "@" + userName, range: range) {
                    
                    string.replaceSubrange(subrange, with: "<@" + userName + ">")
                    guard subrange.upperBound != range.upperBound else {
                        
                        break
                    }
                    range = string.index(subrange.upperBound, offsetBy: 1)..<string.endIndex
                }
            }
            
            if let userID = user.id, let userName = user.name {
                
                var range = string.startIndex..<string.endIndex
                while let subrange = string.range(of: "<@" + userID + ">", range: range) {
                    
                    string.replaceSubrange(subrange, with: "<@" + userName + ">")
                    guard subrange.upperBound != range.upperBound else {
                        
                        break
                    }
                    range = string.index(subrange.upperBound, offsetBy: 1)..<string.endIndex
                }
            }
        })
        
        return string
    }
    
    private func handleMessage(_ message: Message, fromChannelWithID fromChannelID: String, bot fromWorkspaceBot: Bot) {
        
        guard message.user != fromWorkspaceBot.authenticatedUser?.id else {
            
            return
        }
        
        switch message.subtype {
            
        case .none, .some("bot_message"):
            break
            
        default:
            return
        }
        
        // toWorkspaceBot
        
        let toWorkspaceBot: Bot
        
        switch fromWorkspaceBot {
            
        case self.yWorkspaceBot:
            toWorkspaceBot = self.xWorkspaceBot
            
        case self.xWorkspaceBot:
            toWorkspaceBot = self.yWorkspaceBot
            
        default:
            return
        }
        
        // authenticatedUserName && messageCreationDate
        
        guard let authenticatedUserName = fromWorkspaceBot.authenticatedUser?.name else {
            
            return
        }
        
        // primaryOwnerName
        
        let _primaryOwnerName: String?
        switch fromWorkspaceBot {
            
        case self.yWorkspaceBot:
            _primaryOwnerName = self.xWorkspaceBot.primaryOwner?.name
            
        case self.xWorkspaceBot:
            _primaryOwnerName = self.yWorkspaceBot.primaryOwner?.name
            
        default:
            _primaryOwnerName = nil
        }
        
        guard let primaryOwnerName = _primaryOwnerName else {
            
            return
        }
        
        // messageText
        
        let messageText: String?
        
        if var _messageText = message.text {
            
            _messageText = self.replaceNonLinkedUserNamesAndLinkedUserIDsByLinkedUserNames(of: self.xWorkspaceBot.users, in: _messageText)
            _messageText = self.replaceNonLinkedUserNamesAndLinkedUserIDsByLinkedUserNames(of: self.yWorkspaceBot.users, in: _messageText)
            
            if _messageText.contains("<@" + authenticatedUserName + ">") == true && _messageText.contains("<@" + primaryOwnerName + ">") == false  {
                
                _messageText += "\n\n<@" + primaryOwnerName + ">"
            }
            
            messageText = _messageText
        }
        else {
            
            messageText = nil
        }
        
        // toChannelName
        
        let fromChannel = fromWorkspaceBot.channels.first(where: { (channel) -> Bool in
            
            return channel.id == fromChannelID
        })
        
        let toChannel = toWorkspaceBot.channels.first(where: { (channel) -> Bool in
            
            return channel.name == fromChannel?.name
        })
        
        let toChannelName: String
        if fromChannel?.isIM == true {
            
            toChannelName = "@\(primaryOwnerName)"
        }
        else {
            
            guard let fromChannelName = fromChannel?.name else {
                
                return
            }
            
            if toChannel != nil {
                
                toChannelName = fromChannelName
            }
            else {
                
                toChannelName = "@\(primaryOwnerName)"
            }
        }
        
        // authorName && authorIcon
        
        let authorName: String?
        let authorIcon: String?
        
        if let messageUserID = message.user {
            
            let user = fromWorkspaceBot.users.first(where: { (user) -> Bool in
                
                return user.id == messageUserID
            })
            
            if let userName = user?.name, let fromChannelName = fromChannel?.name, toChannel == nil {
                
                authorName = "\(userName) posted in #\(fromChannelName)"
            }
            else {
                
                authorName = user?.name
            }
            
            authorIcon = user?.profile?.image24
        }
        else if let messageBotID = message.botID {
            
            let bot = fromWorkspaceBot.bots.first(where: { (bot) -> Bool in
                
                return bot.id == messageBotID
            })
            
            if let botName = bot?.name, let fromChannelName = fromChannel?.name, toChannel == nil {
                
                authorName = "\(botName) posted in #\(fromChannelName)"
            }
            else {
                
                authorName = bot?.name
            }
            
            authorIcon = bot?.icons?.first?.value as? String
        }
        else {
            
            authorName = nil
            authorIcon = nil
        }
        
        // attachments
        
        let attachmentColorString: String
        
        switch fromWorkspaceBot {
            
        case self.yWorkspaceBot:
            attachmentColorString = self.xWorkspaceBotAttachmentColorString
            
        case self.xWorkspaceBot:
            attachmentColorString = self.yWorkspaceBotAttachmentColorString
            
        default:
            return
        }
        
        let attachments: [Attachment]?
        
        if let _authorName = authorName, let _authorIcon = authorIcon {
            
            var attachmentDictionary = [
                
                "author_name": _authorName,
                "author_icon": _authorIcon,
                "color": attachmentColorString
            ]
            
            if let _messageText = messageText {
                
                attachmentDictionary["text"] = _messageText
            }
            
            let attachment = Attachment(attachment: attachmentDictionary)
            
            if let messageAttachments = message.attachments {
                
                var _attachments = [attachment]
                messageAttachments.forEach({ (_attachement) in
                    
                    guard _attachement.authorName == nil && _attachement.authorLink != nil else {
                        
                        _attachments.append(_attachement)
                        return
                    }
                    
                    var attachmentDictionary = _attachement.dictionary
                    attachmentDictionary["author_name"] = "bot"
                    
                    let _attachement = Attachment(attachment: attachmentDictionary)
                    _attachments.append(_attachement)
                })
                
                attachments = _attachments
            }
            else {
                
                attachments = [attachment]
            }
        }
        else {
            
            attachments = message.attachments
        }
        
        // Send message
        
        toWorkspaceBot.sendMessage(toChannelWithName: toChannelName, attachments: attachments, onFailure: { (error) in
            
            print("[Error]: \(error.localizedDescription)\n[Function]: \(#function)\n[Line]: \(#line)")
        })
    }
    
    // MARK: - BotDelegate
    
    internal func bot(_ bot: Bot, didHandleMessage message: Message) {
        
        let channel = bot.channels.first(where: { (channel) -> Bool in
            
            return channel.id == message.channel
        })
        
        guard let channelID = channel?.id else {
            
            return
        }
        
        self.handleMessage(message, fromChannelWithID: channelID, bot: bot)
    }
}
