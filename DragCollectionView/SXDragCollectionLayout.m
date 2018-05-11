//
//  SXDragCollectionLayout.m
//  MenuDemo
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 孙晓东. All rights reserved.
//

#import "SXDragCollectionLayout.h"
/** 默认的列数 */
static const NSInteger SXDefaultColumnCount = 3;
/** 每一列之间的间距 */
static const CGFloat SXDefaultColumnMargin = 10;
/** 每一行之间的间距 */
static const CGFloat SXDefaultRowMargin = 10;
/** 边缘间距 */
static const UIEdgeInsets SXDefaultEdgeInsets = {10, 10, 10, 10};

@interface SXDragCollectionLayout()

@property (nonatomic,weak)id <SXDragLayoutDelegate> delegate;

/** 存放所有cell的布局属性 */
@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *>*attrsArray;
/** 存放所有列的当前高度 */
@property (nonatomic, strong) NSMutableArray *columnHeights;
/** 内容的高度 */
@property (nonatomic, assign) CGFloat contentHeight;
/**
 列间距
 */
@property (nonatomic)CGFloat sxdColumnMargin;
/**
 列数
 */
@property (nonatomic)NSInteger sxdColumnCount;
/**
 行间距
 */
@property (nonatomic)CGFloat sxdRowMargin;
/**
 collection间距
 */
@property (nonatomic)UIEdgeInsets sxdEdgeInsets;

@end
@implementation SXDragCollectionLayout

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)attrsArray {
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (SXDragCollectionLayout * (^)(CGFloat rowMargin))outerSetRowMargin {
    return ^(CGFloat rowMargin) {
        self.sxdRowMargin = rowMargin;
        return self;
    };
}
- (SXDragCollectionLayout * (^)(CGFloat columnMargin))outerSetcolumnMargin{
    return ^(CGFloat columnMargin) {
        self.sxdColumnMargin = columnMargin;
        return self;
    };
}
- (SXDragCollectionLayout * (^)(NSInteger columnCount))outerSetcolumnCount {
    return ^(NSInteger columnCount) {
        self.sxdColumnCount = columnCount;
        return self;
    };
}
- (SXDragCollectionLayout * (^)(UIEdgeInsets edgeInsets))outerSetedgeInsets {
    return ^(UIEdgeInsets edgeInsets) {
        self.sxdEdgeInsets = edgeInsets;
        return self;
    };
}

- (instancetype)init {
    if (self = [super init]) {
        self.sxdEdgeInsets = SXDefaultEdgeInsets;
        
        self.sxdColumnCount = SXDefaultColumnCount;
        
        self.sxdColumnMargin = SXDefaultColumnMargin;
        
        self.sxdRowMargin = SXDefaultRowMargin;
    }
    return self;
}

+ (SXDragCollectionLayout *)sxdDragLayoutWithDelegate:(id <SXDragLayoutDelegate>)delegate {
    
    SXDragCollectionLayout *layout = [[self alloc] init];
    
    layout.delegate = delegate;
    
    return layout;
}


- (void)prepareLayout {
    [super prepareLayout];
    
    self.contentHeight = 0;
    
    [self.columnHeights removeAllObjects];
    
    //先初始化  存放所有列的当前高度 3个值
    for (NSInteger i = 0; i < self.sxdColumnCount; i++) {
        [self.columnHeights addObject:@(self.sxdEdgeInsets.top)];
    }
    // 清除之前所有的布局属性
    [self.attrsArray removeAllObjects];
    // 开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
}

/**
 * 决定cell的排布
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 创建布局属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // collectionView的宽度
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    
    // 设置布局属性的frame
    CGFloat w = (collectionViewW - self.sxdEdgeInsets.left - self.sxdEdgeInsets.right - (self.sxdColumnCount - 1) * self.sxdColumnMargin) / self.sxdColumnCount;
    
    CGFloat h = [self.delegate waterflowLayout:self collectionView:self.collectionView heightForItemAtIndexPath:indexPath itemWidth:w];
    
    // 找出高度最短的那一列,就把下一个cell,添加到低下
    NSInteger destColumn = 0;
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 1; i < self.sxdColumnCount; i++) {
        // 取得第i列的高度
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    
    CGFloat x = self.sxdEdgeInsets.left + destColumn * (w + self.sxdColumnMargin);
    CGFloat y = minColumnHeight;
    if (y != self.sxdEdgeInsets.top) {
        y += self.sxdRowMargin;
    }
    attrs.frame = CGRectMake(x, y, w, h);
    
    // 更新最短那列的高度
    self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
    
    // 记录内容的高度
    CGFloat columnHeight = [self.columnHeights[destColumn] doubleValue];
    //找出最高的高度
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }
    return attrs;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, self.contentHeight + self.sxdEdgeInsets.bottom);
}



@end
