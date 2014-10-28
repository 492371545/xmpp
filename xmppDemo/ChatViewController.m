//
//  ChatViewController.m
//  xmppDemo
//
//  Created by Mengying Xu on 14-10-22.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "MessageCell.h"

#define padding 20

#define DefaultAppDelegate (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface ChatViewController ()<MessageDelegate>
{
    NSMutableArray *messages;
}
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    messages = [NSMutableArray array];
    
    AppDelegate *del = [self appDelegate];
    
    del.messageDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendAction:(id)sender {
    
    //本地输入框中的信息
    NSString *message = self.messageTextField.text;
    if (message.length > 0)
    {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
        
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"USERID"]];
        //组合
        [mes addChild:body];
        
        
        [[self xmppStream] sendElement:mes];
        self.messageTextField.text = @"";
        [self.messageTextField resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"you" forKey:@"sender"];
        [dictionary setObject:[AppDelegate getCurrentTime] forKey:@"time"];

        [messages addObject:dictionary];
        //重新刷新tableView
        [self.tableView reloadData];
        
    }
}
#pragma mark - tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return   1 ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString *identifier = @ "msgCell" ;
    
    MessageCell *cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if  (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    NSMutableDictionary *dict = [messages objectAtIndex:indexPath.row];
    
    //发送者
    NSString *sender = [dict objectForKey:@"sender"];
    //消息
    NSString *message = [dict objectForKey:@"msg"];
    //时间
    NSString *time = [dict objectForKey:@"time"];
    
    NSDictionary *d = [[NSDictionary alloc] initWithObjectsAndKeys:[UIFont boldSystemFontOfSize:13],NSFontAttributeName, nil];
    
    CGSize textSize =CGSizeMake(260.0, 10000.0);
    CGRect sizemsg = [message boundingRectWithSize:textSize
                                        options:NSStringDrawingUsesFontLeading
                                     attributes:d
                                        context:nil];
    
    sizemsg.size.width +=(padding/2);

    
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
     UIImage *bgImage = nil;
    //发送消息
    if ([sender isEqualToString:@"you"])
    {
        //背景图
        bgImage = [[UIImage imageNamed:@"BlueBubble2"] stretchableImageWithLeftCapWidth:10 topCapHeight:7.5];

        [cell.messageContentView setFrame:CGRectMake(padding, padding/2, sizemsg.size.width, sizemsg.size.height+10)];
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, sizemsg.size.width + padding, sizemsg.size.height + padding)];
    }
    else
    {
        bgImage = [[UIImage imageNamed:@"GreenBubble2"] stretchableImageWithLeftCapWidth:7 topCapHeight:7.5];
        [cell.messageContentView setFrame:CGRectMake(320-sizemsg.size.width - padding, padding/2, sizemsg.size.width, sizemsg.size.height+10)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, sizemsg.size.width + padding, sizemsg.size.height + padding)];
    }
    
        cell.bgImageView.image = bgImage;
        cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
    
    return  cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [messages objectAtIndex:indexPath.row];

    //消息
    NSString *message = [dict objectForKey:@"msg"];
 
    
    NSDictionary *d = [[NSDictionary alloc] initWithObjectsAndKeys:[UIFont boldSystemFontOfSize:13],NSFontAttributeName, nil];
    
    CGSize textSize =CGSizeMake(260.0, 10000.0);
    CGRect sizemsg = [message boundingRectWithSize:textSize
                                           options:NSStringDrawingUsesFontLeading
                                        attributes:d
                                           context:nil];
    
    sizemsg.size.height +=(padding*2);

    CGFloat height = sizemsg.size.height < 65 ? 65 : sizemsg.size.height;
    
    return height;
}

#pragma mark - messageDelegate

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
//取得当前的XMPPStream
- (XMPPStream*)xmppStream
{
    return [self appDelegate].xmppStream;
}

- (void)newMessageReceived:(NSDictionary *)messageContent
{
    [messages addObject:messageContent];
    
    [self.tableView reloadData];
}


@end
