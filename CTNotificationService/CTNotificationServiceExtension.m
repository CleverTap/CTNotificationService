
#import "CTNotificationServiceExtension.h"
#import <objc/message.h>
#import <os/log.h>

static NSString * const kCTNotificationServiceSdkName = @"CTNotificationService";
// Set by scripts/bump_version.sh to match the podspec version and verified by scripts/check_version.sh.
static NSString * const kCTNotificationServiceVersion = @"0.1.8";

// Converts major.minor.patch to major * 10000 + minor * 100 + patch, the format CleverTap Core SDK expects.
static int CTNotificationServiceVersionCode(NSString *version) {
    NSArray<NSString *> *parts = [version componentsSeparatedByString:@"."];
    int major = parts.count > 0 ? parts[0].intValue : 0;
    int minor = parts.count > 1 ? parts[1].intValue : 0;
    int patch = parts.count > 2 ? parts[2].intValue : 0;
    return major * 10000 + minor * 100 + patch;
}

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

// Register in init so this runs before any subclass implementation of
// didReceiveNotificationRequest:withContentHandler:, even if the subclass does not call super.
- (instancetype)init {
    self = [super init];
    if (self) {
        [CTNotificationServiceExtension registerSdkVersionWithCleverTapCore];
    }
    return self;
}

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

// Register the library name and version with CleverTap Core, if available.
// Uses runtime lookup to avoid a compile-time dependency.
// Core ensures registration happens only once per process.
+ (void)registerSdkVersionWithCleverTapCore {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        os_log_t log = os_log_create("com.clevertap.CTNotificationService", "SdkVersion");
        Class cleverTapClass = NSClassFromString(@"CleverTap");
        SEL sharedInstanceSelector = NSSelectorFromString(@"sharedInstance");
        SEL setCustomSdkVersionSelector = NSSelectorFromString(@"setCustomSdkVersion:version:");
        if (!cleverTapClass || ![cleverTapClass respondsToSelector:sharedInstanceSelector]) {
            os_log(log, "CleverTap Core SDK not found, skipping SDK version registration");
            return;
        }
        id cleverTap = ((id (*)(id, SEL))objc_msgSend)(cleverTapClass, sharedInstanceSelector);
        if (!cleverTap) {
            os_log(log, "CleverTap sharedInstance is nil, check CleverTapAccountID and CleverTapToken in the extension Info.plist");
            return;
        }
        if (![cleverTap respondsToSelector:setCustomSdkVersionSelector]) {
            os_log(log, "CleverTap Core SDK does not support setCustomSdkVersion:version:, skipping SDK version registration");
            return;
        }
        int versionCode = CTNotificationServiceVersionCode(kCTNotificationServiceVersion);
        ((void (*)(id, SEL, NSString *, int))objc_msgSend)(cleverTap, setCustomSdkVersionSelector, kCTNotificationServiceSdkName, versionCode);
        os_log(log, "Registered %{public}@ %{public}@ (%d) with CleverTap Core SDK", kCTNotificationServiceSdkName, kCTNotificationServiceVersion, versionCode);
    });
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
