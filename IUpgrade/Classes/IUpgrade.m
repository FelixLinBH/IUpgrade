//
//  IUpgrade.m
//  Pods
//
//  Created by LBH on 2016/8/1.
//
//

#import "IUpgrade.h"
#import "UIResponder+IUpgrade.h"
NSString * const IUpgradeStoredVersionSkipData = @"Upgrade Stored Version Data";

@interface IUpgrade ()
@property (nonatomic, strong) NSDictionary <NSString *, id> *appData;
@property (nonatomic, strong) UIViewController *presentingViewController;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, assign) NSString *plistVersion;
@end


@implementation IUpgrade

+ (IUpgrade *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _type = IUpgradeDefault;
    }
    
    return self;
}

#pragma mark - Set

- (void)setType:(IUpgradeAlertType)type {
    _type = type;
}

#pragma mark - Get

- (NSString *)alertTitle{
    if (!_alertTitle) {
        return @"Upgrade";
    }
    return _alertTitle;
}

- (NSString *)prefixMessage{
    if (!_prefixMessage) {
        return @"Please upgrade to version";
    }
    return _prefixMessage;
}

- (NSString *)suffixMessage{
    if (!_suffixMessage) {
        return @"";
    }
    return _suffixMessage;
}
#pragma mark - Public

- (void)checkVersion {
    if (_alertController == nil) {
        [self performVersionCheck];
    }
}

- (void)CheckVersionForced {
    if (_type != IUpgradeForec) {
        return;
    }
    [self checkVersion];
}

- (void)setAlertTitle:(NSString *)alertTitle prefixMessage:(NSString *)prefixMessage suffixMessage:(NSString *)suffixMessage{
    _alertTitle = alertTitle;
    _prefixMessage = prefixMessage;
    _suffixMessage = suffixMessage;
}


#pragma mark - Helpers
- (void)performVersionCheck {
    
    
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.plistUrlString]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                if ([data length] > 0 && !error) { // Success
                                                    [self parseResults:data];
                                                }
                                            }];
    [task resume];
}

- (void)parseResults:(NSData *)data {
    NSError *error;
    NSPropertyListFormat format;
    _appData = [NSPropertyListSerialization propertyListWithData:data  options:NSPropertyListImmutable format:&format error:&error];
    
    if(!_appData){
        //NSLog(@"Plist fetch error: %@",error);
        return;
    }

    if (![self isCompatibleWithBundleID:_appData]) {
        //NSLog(@"Not compatible with bundle ID");
        return;
    }
    if (![self isNeedToUpdateVersion:_appData]) {
        //NSLog(@"Not need to upgrade version");
        return;
    }
    [self showAlertWithNewVersion:_appData];
}

- (void)initAlertController:(NSString *)title message:(NSString *)message{
    _alertController = [UIAlertController alertControllerWithTitle:title
                                                           message:message
                                                    preferredStyle:UIAlertControllerStyleAlert];
}


- (void)showAlertWithNewVersion:(NSDictionary<NSString *, id> *)appData {
    
    NSString *newVersion = appData[@"items"][0][@"metadata"][@"bundle-version"];
    NSString *message = [NSString stringWithFormat:@"%@ %@ %@",self.prefixMessage,newVersion,self.suffixMessage];
    [self initAlertController:self.alertTitle message:message];
    
    switch (_type) {
        case IUpgradeDefault:{
            [_alertController addAction:[self updateAlertAction]];
            [_alertController addAction:[self nextTimeAlertAction]];
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.presentingViewController presentViewController:_alertController animated:YES completion:nil];
                });
            break;
        }
        case IUpgradeForec:{
            [_alertController addAction:[self updateAlertAction]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.presentingViewController presentViewController:_alertController animated:YES completion:nil];
            });

            break;
        }
        case IUpgradeSkip:{
            [_alertController addAction:[self updateAlertAction]];
            [_alertController addAction:[self skipAlertAction]];
            [_alertController addAction:[self nextTimeAlertAction]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.presentingViewController presentViewController:_alertController animated:YES completion:nil];
            });
            break;
        }
    }
}

- (UIViewController *)presentingViewController{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)launchInstall{
    
    NSString *actionUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",_plistUrlString];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:actionUrl]];
    });
}

- (UIAlertAction *)updateAlertAction {
    UIAlertAction *updateAlertAction = [UIAlertAction actionWithTitle:@"Update"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [self launchInstall];
                                                                  _alertController = nil;
                                                              }];
    
    return updateAlertAction;
}

- (UIAlertAction *)nextTimeAlertAction {
    UIAlertAction *nextTimeAlertAction = [UIAlertAction actionWithTitle:@"Next"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    _alertController = nil;
                                                                }];
    
    return nextTimeAlertAction;
}

- (UIAlertAction *)skipAlertAction {
    UIAlertAction *skipAlertAction = [UIAlertAction actionWithTitle:@"Skip"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                [self storeSkipNewVersion];
                                                                _alertController = nil;
                                                            }];
    
    return skipAlertAction;
}

- (void)storeSkipNewVersion{
    NSMutableDictionary *versionData =
    [[NSUserDefaults standardUserDefaults]objectForKey:IUpgradeStoredVersionSkipData];
    if (versionData == nil) {
        versionData = [NSMutableDictionary new];
    }
    versionData = [versionData mutableCopy];
    [versionData setObject:[NSNumber numberWithBool:YES] forKey:_plistVersion];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:versionData forKey:IUpgradeStoredVersionSkipData];
    [defaults synchronize];
}

- (BOOL)isCompatibleWithBundleID:(NSDictionary<NSString *, id> *)appData {
    return (appData[@"items"][0][@"metadata"][@"bundle-identifier"] == [NSBundle mainBundle].bundleIdentifier);
}

- (BOOL)isNeedToUpdateVersion:(NSDictionary<NSString *, id> *)appData {
    NSString* newVersion = appData[@"items"][0][@"metadata"][@"bundle-version"];
    _plistVersion = newVersion;
    NSMutableDictionary *versionDate = [[NSUserDefaults standardUserDefaults]objectForKey:IUpgradeStoredVersionSkipData];
    
    if ([versionDate objectForKey:newVersion]) {
        return false;
    }
    
    NSString* currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
   
    if (
        ([newVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) ||
        ([newVersion compare:currentVersion options:NSNumericSearch] == NSOrderedSame)
        ) {
        return true;
    } else {
        return false;
    }
}
@end
