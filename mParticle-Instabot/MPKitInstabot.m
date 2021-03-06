#import "MPKitInstabot.h"

@interface MPKitInstabotProxy: NSObject <MPKitInstabotProvider>

@property (nonatomic, strong) ROKOInstaBot *instabot;
@property (nonatomic, strong) ROKOLinkManager *linkManager;

@end

@implementation MPKitInstabotProxy

- (ROKOInstaBot *)getInstaBot {
    @synchronized (self) {
        if (!_instabot) {
            _instabot = [ROKOInstaBot new];
        }
        return _instabot;
    }
}

- (ROKOLinkManager *)getLinkManager {
    @synchronized (self) {
        if (!_linkManager) {
            _linkManager = [ROKOLinkManager new];
        }
        return _linkManager;
    }
}

@end

@interface MPKitInstabot() <ROKOLinkManagerDelegate>

@property (nonatomic, strong) ROKOPush *pusher;
@property (nonatomic, strong) ROKOLinkManager *linkManager;
@property (nonatomic, strong) id <MPKitInstabotProvider> proxy;

@end

@implementation MPKitInstabot

- (id <MPKitInstabotProvider>)proxy {
    @synchronized (self) {
        if (!_proxy) {
            _proxy = [[MPKitInstabotProxy alloc] init];
        }
        return _proxy;
    }
}
+ (NSNumber *)kitCode {
    return @123;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Instabot" className:@"MPKitInstabot"];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;
    
    NSString *appKey = configuration[@"apiKey"];
    if (!appKey) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }
    
    [ROKOComponentManager sharedManager].apiToken = appKey;
    
    _configuration = configuration;
    
    [self start];
    
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (void)start {
    static dispatch_once_t kitPredicate;
    
    dispatch_once(&kitPredicate, ^{
        self->_started = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (id const)providerKitInstance {
    return [self started] ? self.proxy : nil;
}


#pragma mark Application

- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
    [self.proxy.getLinkManager continueUserActivity:userActivity];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
    [self.proxy.getLinkManager handleDeepLink:url];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
    [self.proxy.getLinkManager handleDeepLink:url];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark Push

- (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    if (_pusher) {
        [_pusher handleNotification:userInfo];
    }
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
    _pusher = [[ROKOPush alloc]init];
    [_pusher registerWithAPNToken:deviceToken withCompletion:^(id responseObject, NSError *error) {
        if (error) NSLog(@"Failed to register with error - %@", error);
    }];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark User attributes and identities

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    ROKOPortalManager *portalManager = [ROKOComponentManager sharedManager].portalManager;
    
    [portalManager setUserCustomProperty:value forKey:key completionBlock:^(NSError * _Nullable error) {
        if (error) NSLog(@"%@", error);
    }];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    ROKOPortalManager *portalManager = [ROKOComponentManager sharedManager].portalManager;
    
    if (identityType == MPUserIdentityCustomerId || identityType == MPUserIdentityEmail) {
        [portalManager setUserWithName:identityString referralCode:nil linkShareChannel:nil completionBlock:^(NSError * _Nullable error) {}];
        return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    } else {
        return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeCannotExecute];
    }
}

- (MPKitExecStatus *)logout {
    [[ROKOComponentManager sharedManager].portalManager logoutWithCompletionBlock:^(NSError * _Nullable error) {
        if (error) NSLog(@"%@", error);
    }];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark Events

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    if (event.info) {
        [ROKOLogger addEvent:event.name withParameters:event.info];
    } else {
        [ROKOLogger addEvent:event.name];
    }
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

@end
