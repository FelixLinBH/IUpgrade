//
//  IUpgrade.m
//  Pods
//
//  Created by LBH on 2016/8/1.
//
//

#import "IUpgrade.h"

@interface IUpgrade ()
@property (nonatomic, copy) NSString *currentInstalledVersion;
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
//        _alertType = HarpyAlertTypeOption;
//        _lastVersionCheckPerformedOnDate = [[NSUserDefaults standardUserDefaults] objectForKey:HarpyDefaultStoredVersionCheckDate];
        _currentInstalledVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
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
    

    NSLog( @"plist is %@", _appData );
    if(!_appData){
        NSLog(@"Error: %@",error);
    }
}
@end
