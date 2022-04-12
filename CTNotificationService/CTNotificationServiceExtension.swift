import UserNotifications

open class CTNotificationServiceExtension: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

          self.contentHandler = contentHandler
          bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
          
          // MARK: - CT Rich Push
          if let bestAttemptContent = bestAttemptContent {
//              bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
              let userInfo = request.content.userInfo;

              // If there is no URL in the payload than
              // the code will still show the push notification.
              if userInfo["ct_mediaUrl"] == nil {
                  contentHandler(bestAttemptContent);
                  return;
              }
              
              let mediaType = userInfo["ct_mediaType"] as? String
              let mediaUrl = userInfo["ct_mediaUrl"] as? String
              
              if (mediaUrl != nil) {
                  let mediaUrl = URL(string: mediaUrl!)
                  let CTSession = URLSession(configuration: .default)
                  CTSession.downloadTask(with: mediaUrl!, completionHandler: { temporaryLocation, response, error in
                      if let err = error {
                          print("Error with downloading rich push: \(String(describing: err.localizedDescription))")
                          contentHandler(bestAttemptContent);
                          return;
                      }
                      
                      let fileType = self.fileExtensionForMediaType(fileType: (response?.mimeType)!)
                      let fileName = temporaryLocation?.lastPathComponent.appending(fileType)
                      
                      let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName!)
                      
                      do {
                          try FileManager.default.moveItem(at: temporaryLocation!, to: temporaryDirectory)
                          let attachment = try UNNotificationAttachment(identifier: "", url: temporaryDirectory, options: nil)
                          
                          bestAttemptContent.attachments = [attachment];
                          contentHandler(bestAttemptContent);
                          // The file should be removed automatically from temp
                          // Delete it manually if it is not
                          if FileManager.default.fileExists(atPath: temporaryDirectory.path) {
                              try FileManager.default.removeItem(at: temporaryDirectory)
                          }
                      } catch {
                          print("Error with the rich push attachment: \(error)")
                          contentHandler(bestAttemptContent);
                          return;
                      }
                  }).resume()
                  
              }
          }
      }
      
    open override func serviceExtensionTimeWillExpire() {
          // Called just before the extension will be terminated by the system.
          // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
          if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
              contentHandler(bestAttemptContent)
          }

}

    func fileExtensionForMediaType(fileType: String) -> String {
        // Determines the file type of the attachment to append to URL.
        if fileType == "image/jpeg" {
            return ".jpg";
        }
        if fileType == "image/gif" {
            return ".gif";
        }
        if fileType == "video/mp4" {
            return ".mp4";
        }
        if fileType == "audio/mpeg" {
            return ".mpeg";
        }
        if fileType == "image/png" {
            return ".png";
        } else {
            return ".tmp";
        }
    }

}
