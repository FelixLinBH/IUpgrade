//
//  IUpgrade.h
//  Pods
//
//  Created by LBH on 2016/8/1.
//
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, IUpgradeAlertType)
{
    IUpgradeDefault,
    IUpgradeForec,
    IUpgradeSkip
};

@interface IUpgrade : NSObject
@property (nonatomic) NSString *plistUrlString;
@property (nonatomic) NSString *alertTitle;
@property (nonatomic) NSString *prefixMessage;
@property (nonatomic) NSString *suffixMessage;
@property (nonatomic, assign) IUpgradeAlertType type;

+ (IUpgrade *)sharedInstance;
- (void)checkVersion;
- (void)CheckVersionForced;
- (void)setAlertTitle:(NSString *)alertTitle prefixMessage:(NSString *)prefixMessage suffixMessage:(NSString *)suffixMessage;
@end
