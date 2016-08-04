//
//  IUpgrade.m
//  Pods
//
//  Created by LBH on 2016/8/1.
//
//

#import "IUpgrade.h"

NSString * const IUpgradeStoredVersionData = @"Upgrade Stored Version Data";

@interface IUpgrade ()
@property (nonatomic, strong) NSDictionary <NSString *, id> *appData;
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
    
}


- (BOOL)isCompatibleWithBundleID:(NSDictionary<NSString *, id> *)appData {
    return (appData[@"items"][0][@"metadata"][@"bundle-identifier"] == [NSBundle mainBundle].bundleIdentifier);
}

- (BOOL)isNeedToUpdateVersion:(NSDictionary<NSString *, id> *)appData {
    NSString* newVersion = appData[@"items"][0][@"metadata"][@"bundle-version"];
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
