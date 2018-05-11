//
//  SXDragCollectionLayout.h
//  MenuDemo
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 孙晓东. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SXDragCollectionLayout;
@protocol SXDragLayoutDelegate <NSObject>
@required
- (CGFloat)waterflowLayout:(SXDragCollectionLayout *)waterflowLayout collectionView:(UICollectionView *)collectionView heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;
@end

/**
 瀑布流
 */
@interface SXDragCollectionLayout : UICollectionViewLayout

- (SXDragCollectionLayout * (^)(CGFloat rowMargin))outerSetRowMargin;

- (SXDragCollectionLayout * (^)(CGFloat columnMargin))outerSetcolumnMargin;

- (SXDragCollectionLayout * (^)(NSInteger columnCount))outerSetcolumnCount;

- (SXDragCollectionLayout * (^)(UIEdgeInsets edgeInsets))outerSetedgeInsets;

+ (SXDragCollectionLayout *)sxdDragLayoutWithDelegate:(id <SXDragLayoutDelegate>)delegate;

@end
