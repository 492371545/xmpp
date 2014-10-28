//
//  ViewController.m
//  xmppDemo
//
//  Created by Mengying Xu on 14-10-22.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "LoginViewController.h"
#import "AddFriendsTableViewController.h"

@interface ViewController ()<ChatDelegate>
{
    NSString *chatUserName;
    //在线用户
    NSMutableArray *onlineUsers;
    //下线用户
    NSMutableArray *offlineUsers;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController
- (void )viewDidLoad
{
    [super  viewDidLoad];
    
    onlineUsers = [NSMutableArray array];
    offlineUsers = [NSMutableArray array];
    AppDelegate *del = [self appDelegate];
    
    del.chatDelegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"USERID"];
    
    if(login)
    {
        if([[self appDelegate] connect])
        {
            NSLog(@"show buddy list");
        }
    }
    else
    {
         //设定用户
        [self accountAction:nil];
    }
}

- (IBAction)accountAction:(id)sender {
    
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)addFriends:(id)sender {
    
    
}


#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(section == 0)
    {
        return  [onlineUsers count];

    }
    else
    {
        return  [offlineUsers count];

    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString *identifier = @ "userCell" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if  (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if(indexPath.section == 0)
    {
        cell.textLabel.text = [onlineUsers objectAtIndex:indexPath.row];
        
    }
    else
    {
        cell.textLabel.text = [offlineUsers objectAtIndex:indexPath.row];
        
    }
    return  cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return   2 ;
}
#pragma mark UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"上线用户";
    }
    else
    {
        return @"下线用户";

    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0)
    {
        //start a Chat
        chatUserName = (NSString *)[onlineUsers objectAtIndex:indexPath.row];
        
        ChatViewController *vc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        vc.chatWithUser = chatUserName;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        
    }
  
    
}

#pragma mark - chatDelegate

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
//取得当前的XMPPStream
- (XMPPStream*)xmppStream
{
    return [self appDelegate].xmppStream;
}
//在线好友
- (void)newBuddyOnline:(NSString *)buddyName WithClearArr:(BOOL)isClear
{
//    if(isClear == YES)
//    {
//        [onlineUsers removeAllObjects];
//    }
    
    if(![onlineUsers containsObject:buddyName])
    {
        BOOL hasSame = NO;
        for(NSString *s in onlineUsers)
        {
            if([s isEqualToString:buddyName])
            {
                hasSame = YES;
                break;
            }
        }
        if(hasSame == NO)
        {
            [onlineUsers addObject:buddyName];
            
        }

        for(NSString *s in offlineUsers)
        {

            if([s isEqualToString:buddyName])
            {
                [offlineUsers removeObject:s];
                
            }
            
        }

        [self.tableView reloadData];
    }
    
}
//好友下线
- (void)buddyWentOffline:(NSString *)buddyName WithClearArr:(BOOL)isClear
{
    [onlineUsers removeObject:buddyName];
    
//    if(isClear == YES)
//    {
//        [offlineUsers removeAllObjects];
//    }
    
    BOOL hasSame = NO;
    for(NSString *s in offlineUsers)
    {
        if([s isEqualToString:buddyName])
        {
            hasSame = YES;
            break;
        }
    }
    if(hasSame == NO)
    {
        [offlineUsers addObject:buddyName];

    }
    
    [self.tableView reloadData];

}

@end
