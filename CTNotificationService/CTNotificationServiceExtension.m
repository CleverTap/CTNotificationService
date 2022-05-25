
#import "CTNotificationServiceExtension.h"

static NSString * const kMediaUrlKey = @"ct_mediaUrl";
static NSString * const kMediaTypeKey = @"ct_mediaType";

static NSString * const kImage = @"image";
static NSString * const kVideo = @"video";
static NSString * const kAudio = @"audio";
static NSString * const kImageJpeg = @"image/jpeg";
static NSString * const kImagePng = @"image/png";
static NSString * const kImageGif = @"image/gif";

@interface CTNotificationServiceExtension()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation CTNotificationServiceExtension

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *userInfo = request.content.userInfo;
    if (userInfo == nil) {
        self.contentHandler(self.bestAttemptContent);
        return;
    }
    
    NSString *mediaUrlKey = self.mediaUrlKey ? self.mediaUrlKey : kMediaUrlKey;
    NSString *mediaTypeKey = self.mediaTypeKey ? self.mediaTypeKey : kMediaTypeKey;
    
    NSString *mediaUrl = userInfo[mediaUrlKey];
    NSString *mediaType = userInfo[mediaTypeKey];
    
    if (mediaUrl == nil || mediaType == nil) {
#ifdef DEBUG
        if (mediaUrl == nil) {
            NSLog(@"unable to add attachment: %@ is nil", mediaUrlKey);
        }
        
        if (mediaType == nil) {
            NSLog(@"unable to add attachment: %@ is nil", mediaTypeKey);
        }
        
#endif
        self.contentHandler(self.bestAttemptContent);
        return;
    }
    
    // load the attachment
    [self loadAttachmentForUrlString:mediaUrl
                            withType:mediaType
                   completionHandler:^(UNNotificationAttachment *attachment) {
        if (attachment) {
            self.bestAttemptContent.attachments = [NSArray arrayWithObject:attachment];
        }
        self.contentHandler(self.bestAttemptContent);
    }];
    
}

- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

- (NSString *)fileExtensionForMediaType:(NSString *)mediaType mimeType:(NSString *)mimeType {
    NSString *ext;
    
    if ([mediaType isEqualToString:kImage]) {
        ext = @"jpg";
    } else if ([mediaType isEqualToString:kVideo]) {
        ext = @"mp4";
    } else if ([mediaType isEqualToString:kAudio]) {
        ext = @"mp3";
    } else {
        // If mediaType is none, check for mimeType of url.
        if ([mimeType isEqualToString:kImageJpeg]) {
            ext = @"jpeg";
        } else if ([mimeType isEqualToString:kImagePng]) {
            ext = @"png";
        } else if ([mimeType isEqualToString:kImageGif]) {
            ext = @"gif";
        } else {
            ext = @"";
        }
    }
    
    return [@"." stringByAppendingString:ext];
}

- (void)loadAttachmentForUrlString:(NSString *)urlString withType:(NSString *)mediaType
                 completionHandler:(void(^)(UNNotificationAttachment *))completionHandler  {
    
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL
                completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        if (error != nil) {
#ifdef DEBUG
            NSLog(@"unable to add attachment: %@", error.localizedDescription);
#endif
        } else {
            NSString *fileExt = [self fileExtensionForMediaType:mediaType mimeType:response.MIMEType];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
            [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
            
            NSError *attachmentError = nil;
            attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
            if (attachmentError) {
#ifdef DEBUG
                NSLog(@"unable to add attchment: %@", attachmentError.localizedDescription);
#endif
            }
        }
        completionHandler(attachment);
    }] resume];
}


@end
