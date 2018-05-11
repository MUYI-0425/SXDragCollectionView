//
//  UIView+Tool.m
//  MenuDemo
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 孙晓东. All rights reserved.
//

#import "UIView+Tool.h"
#import <objc/runtime.h>
const NSString *UIView_LongPressGestureRecognizer_gesturesKey = @"UIView_LongPressGestureRecognizer_gesturesKey";
@implementation UIView (Tool)
@dynamic longPressGestureRecognizer;
- (void)addLongPressAction:(void (^)(UILongPressGestureRecognizer *longPress))LongPress {
    self.longPressGestureRecognizer = LongPress;
    
    UILongPressGestureRecognizer *xdLongP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    
    [self addGestureRecognizer:xdLongP];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)ges {
    if (self.longPressGestureRecognizer) {
        self.longPressGestureRecognizer(ges);
    }
}

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (void)setLongPressGestureRecognizer:(LongPress)longPressGestureRecognizer {
    objc_setAssociatedObject(self, &UIView_LongPressGestureRecognizer_gesturesKey, longPressGestureRecognizer, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (LongPress)longPressGestureRecognizer {
    return objc_getAssociatedObject(self, &UIView_LongPressGestureRecognizer_gesturesKey);
}


@end
