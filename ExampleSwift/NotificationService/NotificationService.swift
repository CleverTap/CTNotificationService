
import CTNotificationService

class NotificationService: CTNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.mediaUrlKey = "myMediaUrlKey"
        self.mediaTypeKey = "myMediaTypeKey"
        
        super.didReceive(request, withContentHandler: contentHandler)
    }
}
