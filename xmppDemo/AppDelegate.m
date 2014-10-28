//
//  AppDelegate.m
//  xmppDemo
//
//  Created by Mengying Xu on 14-10-22.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
@implementation AppDelegate

- (void)setupStream
{
    //初始化XMPPStream
    _xmppStream = [[XMPPStream alloc] init];
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)goOnline
{
     //发送在线状态
    XMPPPresence *pre = [XMPPPresence presence];
    
    [[self xmppStream] sendElement:pre];
}

-(void)goOffline{
    
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
    
}

- (void)disconnect
{
    [self goOffline];
    [_xmppStream disconnect];
}

- (BOOL)connect
{
    [self setupStream];
    
    //从本地取得用户名，密码和服务器地址
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userId = [defaults stringForKey:@"USERID"];
    NSString *pass = [defaults stringForKey:@"PASS"];
    NSString *server = [defaults stringForKey:@"SERVER"];

    if(![_xmppStream isDisconnected])
    {
        return YES;
    }
    
    if(userId == nil || pass == nil || server == nil)
    {
        return NO;
    }
    //设置用户
    [_xmppStream setMyJID:[XMPPJID jidWithString:userId]];
      //设置服务器
    [_xmppStream setHostName:server];
      //密码
    password = pass;
    
     //连接服务器 
    NSError *error = nil;
    
    if(![_xmppStream connectWithTimeout:60 error:&error])
    {
        NSLog(@"cant connect %@", server);
        return NO;
    }
    
    return YES;

}

#pragma mark -xmppStream Delegate
//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    isopen = YES;
    NSError *error = nil;
    
    [self.xmppStream authenticateWithPassword:password error:&error];
}
//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"sender = %@", sender);
    //当前用户
    NSString *userId = [[sender myJID] user];
    
    [self goOnline];
}

//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"message = %@", message);  
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if(msg)
    {
        [dict setObject:msg forKey:@"msg"];
        [dict setObject:from forKey:@"sender"];
        [dict setObject:[AppDelegate getCurrentTime] forKey:@"time"];
        
        //消息委托
        [_messageDelegate newMessageReceived:dict];
    }
    
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
   
     NSLog(@"presence = %@", presence);
    //取得好友状态
    NSString *presenceType = [presence type];
    //当前用户
    NSString *userId = [[sender myJID] user];
      //在线用户
    NSString *presenceFromUser = [[presence from] user];
    
    NSLog(@"当前用户：%@",userId);
    
    if(![presenceFromUser isEqualToString:userId])
    { //在线状态
        if([presenceType isEqualToString:@"available"])
        {
            //从本地取得用户名，密码和服务器地址
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            NSString *userId2 = [defaults stringForKey:@"USERID"];
            if([userId2 isEqualToString:userId])
            {
                //用户列表委托
                [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@",presenceFromUser,@"xmydemac-mini.local"] WithClearArr:NO];
            }
            else
            {
                //用户列表委托
                [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@",presenceFromUser,@"xmydemac-mini.local"] WithClearArr:YES];
            }
          
        }
        else
        {
            for(UIViewController *vc in ((UIViewController*)((AppDelegate*)[UIApplication sharedApplication].delegate).nextResponder).navigationController.viewControllers )
            {
                if([vc isKindOfClass:[ChatViewController class]])
                {
                    ChatViewController *v = (ChatViewController*)vc;
                    if([v.title isEqualToString:presenceFromUser])
                    {
                        [v.navigationController popViewControllerAnimated:YES];
                        return;
                    }
                }
            }

            //从本地取得用户名，密码和服务器地址
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            NSString *userId2 = [defaults stringForKey:@"USERID"];
            if([userId2 isEqualToString:userId])
            {
                //用户列表委托
                [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"xmydemac-mini.local"] WithClearArr:NO];
            }
            else
            {
                //用户列表委托
                [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"xmydemac-mini.local"] WithClearArr:YES];
            }

        }
    }
    
}


- (void)xmppStream:(XMPPStream *)sender willSendP2PFeatures:(DDXMLElement *)streamFeatures
{
    NSLog(@"11streamFeatures = %@", streamFeatures);

}
- (void)xmppStream:(XMPPStream *)sender didReceiveP2PFeatures:(DDXMLElement *)streamFeatures
{
    NSLog(@"22streamFeatures = %@", streamFeatures);

}

+(NSString*)getCurrentTime
{
    NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    
    return [dateFormatter stringFromDate:nowUTC];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
