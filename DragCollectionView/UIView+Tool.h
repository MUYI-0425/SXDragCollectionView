//
//  UIView+Tool.h
//  MenuDemo
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 孙晓东. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LongPress)(UILongPressGestureRecognizer *longPress);

@interface UIView (Tool)

@property (nonatomic,copy)LongPress longPressGestureRecognizer;

- (void)addLongPressAction:(LongPress )LongPress;

- (UIImage *)snapshotImage;
@end
