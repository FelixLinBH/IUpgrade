//
//  UIResponder+IUpgrade.m
//  Pods
//
//  Created by LBH on 2016/8/8.
//
//

#import "UIResponder+IUpgrade.h"
#import "objc/runtime.h"
#import "IUpgrade.h"

@implementation UIResponder (IUpgrade)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class selfClass = [self class];
        Class appdelegateClass = [self getAppDelegate];
        SEL oriSEL = @selector(applicationWillEnterForeground:);
        Method oriMethod = class_getInstanceMethod(appdelegateClass, oriSEL);
        
  
        SEL cusSEL = @selector(IUpgradeApplicationWillEnterForeground:);
        Method cusMethod = class_getInstanceMethod(selfClass, cusSEL);
        
        
        BOOL addSucc = class_addMethod(appdelegateClass, oriSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
        if (addSucc) {
            class_replaceMethod(appdelegateClass, cusSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
        }else {
            method_exchangeImplementations(oriMethod, cusMethod);
        }
        
    });

}

+ (Class) getAppDelegate{
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

- (void)IUpgradeApplicationWillEnterForeground:(UIApplication *)application{
    [self IUpgradeApplicationWillEnterForeground:application];
    [[IUpgrade sharedInstance]CheckVersionForced];
}
@end
