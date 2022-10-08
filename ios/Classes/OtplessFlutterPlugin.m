#import "OtplessFlutterPlugin.h"
#if __has_include(<otpless_flutter/otpless_flutter-Swift.h>)
#import <otpless_flutter/otpless_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "otpless_flutter-Swift.h"
#endif

@implementation OtplessFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOtplessFlutterPlugin registerWithRegistrar:registrar];
}
@end
