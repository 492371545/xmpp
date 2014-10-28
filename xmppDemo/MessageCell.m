//
//  MessageCell.m
//  xmppDemo
//
//  Created by Mengying Xu on 14-10-24.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //日期标签
        _senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        //居中显示
        _senderAndTimeLabel.textAlignment = NSTextAlignmentCenter;
        _senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        //文字颜色
        _senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_senderAndTimeLabel];
        
        //背景图
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bgImageView];
        
        //聊天信息
        _messageContentView = [[UITextView alloc] init];
        _messageContentView.backgroundColor = [UIColor clearColor];
        //不可编辑
        _messageContentView.editable = NO;
        _messageContentView.scrollEnabled = NO;
        [_messageContentView sizeToFit];
        [self.contentView addSubview:_messageContentView];
        
    }
    
    return self;
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
