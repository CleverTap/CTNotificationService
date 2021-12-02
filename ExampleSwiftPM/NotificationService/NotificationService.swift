//
//  NotificationService.swift
//  NotificationService
//
//  Created by Aditi Agrawal on 18/09/21.
//

import CTNotificationService

class NotificationService: CTNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        super.didReceive(request, withContentHandler: contentHandler)
    }
}

