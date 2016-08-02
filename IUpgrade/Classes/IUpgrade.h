//
//  IUpgrade.h
//  Pods
//
//  Created by LBH on 2016/8/1.
//
//

#import <Foundation/Foundation.h>

@interface IUpgrade : NSObject
@property (nonatomic) NSString *plistUrlString;
+ (IUpgrade *)sharedInstance;
- (void)checkVersion;
@end
