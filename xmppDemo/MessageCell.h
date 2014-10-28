//
//  MessageCell.h
//  xmppDemo
//
//  Created by Mengying Xu on 14-10-24.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (nonatomic,strong)UILabel *senderAndTimeLabel;
@property (nonatomic,strong)UITextView *messageContentView;
@property (nonatomic,strong)UIImageView *bgImageView;

@end
