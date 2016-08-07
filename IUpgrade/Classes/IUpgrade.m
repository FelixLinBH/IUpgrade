//
//  IUpgrade.m
//  Pods
//
//  Created by LBH on 2016/8/1.
//
//

#import "IUpgrade.h"
#import "objc/runtime.h"
NSString * const IUpgradeStoredVersionSkipData = @"Upgrade Stored Version Data";

@interface IUpgrade ()
@property (nonatomic, strong) NSDictionary <NSString *, id> *appData;
@property (nonatomic, strong) UIViewController *presentingViewController;
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

- (void)setType:(IUpgradeAlertType)type {
    _type = type;
    if (type == IUpgradeForec) {
        [self swizzlingAppDelegate];
    }
}

#pragma mark - Swizzling AppDelegate

- (Class) getAppDelegate{
    unsigned int numberOfClasses = 0;
    Class *classes = objc_copyClassList(&numberOfClasses);
    Class appDelegateClass = nil;
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        if (class_conformsToProtocol(classes[i], @protocol(UIApplicationDelegate))) {
            appDelegateClass = classes[i];
        }
    }
    return appDelegateClass;
}

- (void)swizzlingAppDelegate{
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class selfClass = [self class];
        Class appDelegateClass = [self getAppDelegate];
        SEL oriSEL = @selector(applicationWillEnterForeground:);
        Method oriMethod = class_getInstanceMethod(appDelegateClass, oriSEL);
        
        SEL cusSEL = @selector(IUpgradeApplicationWillEnterForeground:);
        Method cusMethod = class_getInstanceMethod(selfClass, cusSEL);
        
        BOOL addSucc = class_addMethod(appDelegateClass, oriSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
        if (addSucc) {
            class_replaceMethod(appDelegateClass, cusSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
        }else {
            method_exchangeImplementations(oriMethod, cusMethod);
        }
        
    });

}
- (void)IUpgradeApplicationWillEnterForeground:(UIApplication *)application
{
    [[IUpgrade sharedInstance]checkVersion];
    [self IUpgradeApplicationWillEnterForeground:application];
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
            [alertController addAction:[self nextTimeAlertAction]];
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.presentingViewController presentViewController:alertController animated:YES completion:nil];
                });
            break;
        }
        case IUpgradeForec:{
            [alertController addAction:[self updateAlertAction]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.presentingViewController presentViewController:alertController animated:YES completion:nil];
            });

            break;
        }
        case IUpgradeSkip:{
            [alertController addAction:[self updateAlertAction]];
            [alertController addAction:[self skipAlertAction]];
            [alertController addAction:[self nextTimeAlertAction]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.presentingViewController presentViewController:alertController animated:YES completion:nil];
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
                                                              }];
    
    return updateAlertAction;
}

- (UIAlertAction *)nextTimeAlertAction {
    UIAlertAction *nextTimeAlertAction = [UIAlertAction actionWithTitle:@"Next"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {

                                                                }];
    
    return nextTimeAlertAction;
}

- (UIAlertAction *)skipAlertAction {
    UIAlertAction *skipAlertAction = [UIAlertAction actionWithTitle:@"Skip"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                [self storeSkipNewVersion];
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
