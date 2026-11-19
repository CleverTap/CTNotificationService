Pod::Spec.new do |s|
  s.name             = "CTNotificationService"
  s.version          = "1.0.0"
  s.summary          = "A simple Notification Service Extension class to add media attachments to iOS 15 rich push notifications."
  s.description      = <<-DESC
                       A simple Notification Service Extension class to add media attachments to iOS 15 rich push notifications.

                       NOTICE: CocoaPods trunk becomes read-only on December 2, 2026. To keep
                       receiving CleverTap updates through CocoaPods, add these lines to your Podfile:
                         source 'https://github.com/CleverTap/podspecs.git'
                         source 'https://cdn.cocoapods.org/'
                       Existing installs are unaffected. See the README.
                       DESC
  s.homepage         = "https://github.com/CleverTap/CTNotificationService"
  s.license          = "MIT" 
  s.author           = { "CleverTap" => "http://www.clevertap.com" }
  s.source           = { :git => "https://github.com/CleverTap/CTNotificationService.git", :tag => s.version.to_s }
  s.requires_arc     = true
  s.platform         = :ios, '15.0'
  s.weak_frameworks  = 'UserNotifications'
  s.source_files     = 'CTNotificationService/*.{m,h}' 
  s.resource_bundles = { 'CTNotificationService' => 'CTNotificationService/*.{xcprivacy}' }
end
