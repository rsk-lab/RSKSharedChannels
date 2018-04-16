//
// Environment.swift
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

internal struct Environment {
    
    // MARK: - Internal Static Properties
    
    internal static var port: in_port_t {
        
        return in_port_t(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080
    }
    
    internal static var xWorkspaceBotAPITokenString: String {
        
        return ProcessInfo.processInfo.environment["xWorkspaceBotAPITokenString"] ?? "___placeholder___"
    }
    
    internal static var xWorkspaceBotAttachmentColorString: String {
        
        return ProcessInfo.processInfo.environment["xWorkspaceBotAttachmentColorString"] ?? "#359FCE"
    }
    
    internal static var xWorkspaceSlashCommandPath: String {
        
        return ProcessInfo.processInfo.environment["xWorkspaceSlashCommandPath"] ?? "___placeholder___"
    }
    
    internal static var xWorkspaceSlashCommandTokenString: String {
        
        return ProcessInfo.processInfo.environment["xWorkspaceSlashCommandTokenString"] ?? "___placeholder___"
    }
    
    internal static var yWorkspaceBotAPITokenString: String {
        
        return ProcessInfo.processInfo.environment["yWorkspaceBotAPITokenString"] ?? "___placeholder___"
    }
    
    internal static var yWorkspaceBotAttachmentColorString: String {
        
        return ProcessInfo.processInfo.environment["yWorkspaceBotAttachmentColorString"] ?? "#00ABBD"
    }
    
    internal static var yWorkspaceSlashCommandPath: String {
        
        return ProcessInfo.processInfo.environment["yWorkspaceSlashCommandPath"] ?? "___placeholder___"
    }
    
    internal static var yWorkspaceSlashCommandTokenString: String {
        
        return ProcessInfo.processInfo.environment["yWorkspaceSlashCommandTokenString"] ?? "___placeholder___"
    }
}
