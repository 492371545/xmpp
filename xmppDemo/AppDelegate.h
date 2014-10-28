//
//  AppDelegate.h
//  xmppDemo
//
//  Created by Mengying Xu on 14-10-22.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"

@protocol MessageDelegate <NSObject>

- (void)newMessageReceived:(NSDictionary*)messageContent;
@end


@protocol ChatDelegate <NSObject>

- (void)newBuddyOnline:(NSString*)buddyName WithClearArr:(BOOL)isClear;
- (void)buddyWentOffline:(NSString*)buddyName  WithClearArr:(BOOL)isClear;
- (void)didDisconnect;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate,XMPPStreamDelegate>
{
    NSString *password;
    BOOL isopen; //xmppStream是否开着
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (assign, nonatomic) id<ChatDelegate>chatDelegate;
@property (assign, nonatomic)  id<MessageDelegate>messageDelegate;

+(NSString*)getCurrentTime;

//是否连接
- (BOOL)connect;
//断开连接
- (void)disconnect;
//设置XMPPStream
- (void)setupStream;
//上线
- (void)goOnline;
//下线
- (void)goOffline;

@end
