#import "NativeSettingsShd.h"
#import <Cordova/CDVPlugin.h>

@implementation NativeSettingsShd

- (BOOL)do_open:(NSString *)pref {
    NSURL *url = [NSURL URLWithString:pref];
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    SEL sharedApplicationSelector = @selector(sharedApplication);
    id (*sharedApplicationIMP)(id, SEL) = (id (*)(id, SEL))[UIApplicationClass methodForSelector:sharedApplicationSelector];
    id application = sharedApplicationIMP(UIApplicationClass, sharedApplicationSelector);

    SEL canOpenURLSelector = @selector(canOpenURL:);
    BOOL (*canOpenURLIMP)(id, SEL, NSURL *) = (BOOL (*)(id, SEL, NSURL *))[application methodForSelector:canOpenURLSelector];

    if (canOpenURLIMP(application, canOpenURLSelector, url)) {
        SEL openURLSelector = @selector(openURL:options:completionHandler:);
        void (*openURLIMP)(id, SEL, NSURL *, NSDictionary *, void (^)(BOOL)) = (void (*)(id, SEL, NSURL *, NSDictionary *, void (^)(BOOL)))[application methodForSelector:openURLSelector];

        if (openURLIMP) {
            openURLIMP(application, openURLSelector, url, @{}, ^(BOOL success) {
                if (!success) {
                    NSLog(@"Failed to open URL: %@", pref);
                }
            });
            return YES;
        } else {
            NSLog(@"openURL:options:completionHandler: method not available");
            return NO;
        }
    } else {
        NSLog(@"Cannot open URL: %@", pref);
        return NO;
    }
}

- (void)open:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* key = nil;

    if (command.arguments.count > 0) {
        key = [command.arguments objectAtIndex:0];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No setting key provided"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

     NSDictionary *settingsPaths = @{
            @"about": @"App-prefs:General&path=About",
            @"accessibility": @"App-prefs:ACCESSIBILITY",
            @"account": @"App-prefs:ACCOUNT_SETTINGS",
            @"autolock": @"App-prefs:General&path=AUTOLOCK",
            @"display": @"App-prefs:DISPLAY",
            @"bluetooth": @"App-prefs:Bluetooth",
            @"castle": @"App-prefs:CASTLE",
            @"cellular_usage": @"App-prefs:General&path=USAGE/CELLULAR_USAGE",
            @"configuration_list": @"App-prefs:General&path=ManagedConfigurationList",
            @"date": @"App-prefs:General&path=DATE_AND_TIME",
            @"facetime": @"App-prefs:FACETIME",
            @"general": @"App-prefs:General",
            @"tethering": @"App-prefs:INTERNET_TETHERING",
            @"music": @"App-prefs:MUSIC",
            @"music_equalizer": @"App-prefs:MUSIC&path=EQ",
            @"music_volume": @"App-prefs:MUSIC&path=VolumeLimit",
            @"keyboard": @"App-prefs:General&path=Keyboard",
            @"locale": @"App-prefs:General&path=INTERNATIONAL",
            @"location": @"App-prefs:Privacy&path=LOCATION",
            @"tracking": @"App-prefs:Privacy&path=USER_TRACKING",
            @"network": @"App-prefs:General&path=Network",
            @"notes": @"App-prefs:NOTES",
            @"notifications": @"App-prefs:NOTIFICATIONS_ID",
            @"phone": @"App-prefs:Phone",
            @"photos": @"App-prefs:Photos",
            @"managed_configuration_list": @"App-prefs:General&path=ManagedConfigurationList",
            @"reset": @"App-prefs:General&path=Reset",
            @"ringtone": @"App-prefs:Sounds&path=Ringtone",
            @"sounds": @"App-prefs:Sounds",
            @"software_update": @"App-prefs:General&path=SOFTWARE_UPDATE_LINK",
            @"storage": @"App-prefs:CASTLE&path=STORAGE_AND_BACKUP",
            @"store": @"App-prefs:STORE",
            @"usage": @"App-prefs:General&path=USAGE",
            @"video": @"App-prefs:VIDEO",
            @"vpn": @"App-prefs:General&path=VPN",
            @"wallpaper": @"App-prefs:Wallpaper",
            @"wifi": @"App-prefs:WIFI",
            @"touch": @"App-prefs:TOUCHID_PASSCODE",
            @"battery": @"App-prefs:BATTERY_USAGE",
            @"privacy": @"App-prefs:Privacy",
            @"do_not_disturb": @"App-prefs:DO_NOT_DISTURB",
            @"keyboards": @"App-prefs:General&path=Keyboard/KEYBOARDS",
            @"mobile_data": @"App-prefs:MOBILE_DATA_SETTINGS_ID",
            @"screen_time": @"App-prefs:SCREEN_TIME",
            @"application_details": @"",
            @"settings": @"App-prefs:root=",
        };

    NSString* settingsUrlString = settingsPaths[key];

    if ([key isEqualToString:@"application_details"]) {
        settingsUrlString = UIApplicationOpenSettingsURLString;
    } else if (settingsUrlString == nil || [settingsUrlString length] == 0) {
        NSLog(@"Invalid setting key: %@", key);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid setting key"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    BOOL result = [self do_open:settingsUrlString];

    if (result) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Opened"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot open settings"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
