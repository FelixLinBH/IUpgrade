//
//  IUpgrade.m
//  Pods
//
//  Created by LBH on 2016/8/1.
//
//

#import "IUpgrade.h"

NSString * const IUpgradeStoredVersionSkipData = @"Upgrade Stored Version Data";

@interface IUpgrade ()
@property (nonatomic, strong) NSDictionary <NSString *, id> *appData;
@property (nonatomic, strong) UIViewController *presentingViewController;
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

+ (void)setInstallURLString:(NSString *) urlString {
    
}

- (id)init {
    self = [super init];
    
    if (self) {
        _type = IUpgradeDefault;
//        _alertType = HarpyAlertTypeOption;
//        _lastVersionCheckPerformedOnDate = [[NSUserDefaults standardUserDefaults] objectForKey:HarpyDefaultStoredVersionCheckDate];
//        _currentInstalledVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }
    
    return self;
}

- (NSURL *)installURL {
    
}

#pragma mark - Public

- (void)checkVersion {
    [self performVersionCheck];
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
    NSString *error;
    NSPropertyListFormat format;
    _appData = [NSPropertyListSerialization propertyListWithData:data  options:NSPropertyListImmutable format:&format error:&error];
    
    if(!_appData){
        NSLog(@"Plist fetch error: %@",error);
    }

    if (![self isCompatibleWithBundleID:_appData]) {
        NSLog(@"Not compatible with bundle ID");
    }
    if (![self isNeedToUpdateVersion:_appData]) {
        NSLog(@"Not need to upgrade version");
    }
    [self showAlertWithNewVersion:_appData];
}

- (void)showAlertWithNewVersion:(NSDictionary<NSString *, id> *)appData {
    NSString *newVersion = appData[@"items"][0][@"metadata"][@"bundle-version"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"title"
                                                                             message:@"message"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    switch (_type) {
        case IUpgradeDefault:{
            [alertController addAction:[self updateAlertAction]];
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.presentingViewController presentViewController:alertController animated:YES completion:nil];
                });
            
            
        
            break;
        }
        case IUpgradeForec:
            
            break;
        case IUpgradeSkip:
            
            break;
    }
}

- (UIViewController *)presentingViewController{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (UIAlertAction *)updateAlertAction {
    UIAlertAction *updateAlertAction = [UIAlertAction actionWithTitle:@"Update"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
//                                                                  [self launchAppStore];
                                                              }];
    
    return updateAlertAction;
}

- (UIAlertAction *)nextTimeAlertAction {
    UIAlertAction *nextTimeAlertAction = [UIAlertAction actionWithTitle:@"next"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
//                                                                    if([self.delegate respondsToSelector:@selector(harpyUserDidCancel)]){
//                                                                        [self.delegate harpyUserDidCancel];
//                                                                    }
                                                                }];
    
    return nextTimeAlertAction;
}

- (UIAlertAction *)skipAlertAction {
    UIAlertAction *skipAlertAction = [UIAlertAction actionWithTitle:@"Skip"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
//                                                                [[NSUserDefaults standardUserDefaults] setObject:_currentAppStoreVersion forKey:HarpyDefaultSkippedVersion];
//                                                                [[NSUserDefaults standardUserDefaults] synchronize];
//                                                                if([self.delegate respondsToSelector:@selector(harpyUserDidSkipVersion)]){
//                                                                    [self.delegate harpyUserDidSkipVersion];
//                                                                }
                                                            }];
    
    return skipAlertAction;
}


- (BOOL)isCompatibleWithBundleID:(NSDictionary<NSString *, id> *)appData {
    return (appData[@"items"][0][@"metadata"][@"bundle-identifier"] == [NSBundle mainBundle].bundleIdentifier);
}

- (BOOL)isNeedToUpdateVersion:(NSDictionary<NSString *, id> *)appData {
    NSString* newVersion = appData[@"items"][0][@"metadata"][@"bundle-version"];
    
    NSDictionary *versionDate = [[NSUserDefaults standardUserDefaults]objectForKey:IUpgradeStoredVersionSkipData];
    
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
