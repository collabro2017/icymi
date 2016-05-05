//
//  YFInputBar.h
//  test
//
//  Created by 杨峰 on 13-11-10.
//  Copyright (c) 2013年 杨峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YFInputBar;
@protocol YFInputBarDelegate <NSObject>

-(void)inputBar:(YFInputBar*)inputBar sendBtnPress:(UIButton*)sendBtn withInputString:(NSString*)str;

@end
@interface YFInputBar : UIView

//代理 用于传递btn事件
@property(assign,nonatomic)id<YFInputBarDelegate> delegate;
//这两个可以自己付值
@property(strong,nonatomic)UITextField *textField;
@property(strong,nonatomic)UIButton *sendBtn;

//点击btn时候 清空textfield  默认NO
@property(assign,nonatomic)BOOL clearInputWhenSend;
//点击btn时候 隐藏键盘  默认NO
@property(assign,nonatomic)BOOL resignFirstResponderWhenSend;

//初始frame
@property(assign,nonatomic)CGRect originalFrame;

//隐藏键盘
-(BOOL)resignFirstResponder;
@end
