//
//  SXDragViewController.m
//  MenuDemo
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 孙晓东. All rights reserved.
//

#import "SXDragViewController.h"
#import "SXDragCollectionLayout.h"
#import "UIView+Tool.h"
@interface SXDragViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SXDragLayoutDelegate>
@property (nonatomic,strong)UICollectionView *collectionView;

/**
 中间件,视觉效果
 */
@property (nonatomic,strong)UIImageView *snapImgView;

/**
 开始长按拖拽的点
 */
@property (nonatomic,assign)CGPoint beginPoint;

/**
 最后移动到的位置
 */
@property (nonatomic,strong)NSIndexPath *lastMoveIndexPath;

/**
 模拟瀑布流的高度
 */
@property (nonatomic,strong)NSMutableArray *heightDB;

@end

@implementation SXDragViewController

- (NSMutableArray *)heightDB {
    if (!_heightDB) {
        _heightDB = [NSMutableArray arrayWithCapacity:12];
        for (int i = 0; i < 12; i++) {
            [_heightDB addObject:@(arc4random()%200 + 100)];
        }
    }
    return _heightDB;
}

- (UIImageView *)snapImgView {
    if (!_snapImgView) {
        _snapImgView = [[UIImageView alloc] init];
        _snapImgView.userInteractionEnabled = YES;
        [self.collectionView addSubview:_snapImgView];
    }
    return _snapImgView;
}

/**
 这里未封装collection，可根据实际需要封装
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    SXDragCollectionLayout *layout = [SXDragCollectionLayout sxdDragLayoutWithDelegate:self];
    
    layout.outerSetRowMargin(5).outerSetcolumnCount(4).outerSetcolumnMargin(5).
    outerSetedgeInsets(UIEdgeInsetsMake(5, 5, 5, 5));
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) collectionViewLayout:layout];
    
    __weak typeof(self) ws = self;
    
    [self.collectionView addLongPressAction:^(UILongPressGestureRecognizer *longPress) {
    
        if (longPress.state == UIGestureRecognizerStateBegan) {
            
            CGPoint currentPoint = [longPress locationInView:ws.collectionView];
            
            NSIndexPath *currentIndexPath = [ws.collectionView indexPathForItemAtPoint:currentPoint];
            
            if (!currentIndexPath) {
                return ;
            }
            
            UICollectionViewCell *currentCell = [ws.collectionView cellForItemAtIndexPath:currentIndexPath];
            
            if (!currentCell) {
                return;
            }
            
            ws.beginPoint = currentPoint;
            ws.lastMoveIndexPath = currentIndexPath;
            
            ws.snapImgView.transform = CGAffineTransformIdentity;
            ws.snapImgView.image = [currentCell snapshotImage];
            ws.snapImgView.frame = currentCell.frame;
            
            [UIView animateWithDuration:0.3 animations:^{
                ws.snapImgView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                ws.snapImgView.alpha = 1;
                currentCell.alpha = 0;
            }];

        }
        
        if (longPress.state == UIGestureRecognizerStateChanged) {
            if (!ws.lastMoveIndexPath) {
                return;
            }
            UICollectionViewCell *moveCell = [ws.collectionView cellForItemAtIndexPath:ws.lastMoveIndexPath];
            
            if (!moveCell) {
                return;
            }
            
            // 防止手指刚按下就抬起来
            moveCell.hidden = YES;
            
            CGPoint movePoint = [longPress locationInView:ws.collectionView];
            
            CGPoint transltion = CGPointMake(movePoint.x - ws.beginPoint.x, movePoint.y - ws.beginPoint.y);
            
            ws.snapImgView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1.2, 1.2), transltion.x, transltion.y);
            
            [ws.collectionView bringSubviewToFront:ws.snapImgView];
            
            NSIndexPath *moveIndexPath = [ws.collectionView indexPathForItemAtPoint:movePoint];
            
            if (!moveIndexPath) {
                return;
            }
            
            UICollectionViewCell *moveingCell = [ws.collectionView cellForItemAtIndexPath:moveIndexPath];
            
            if (!moveingCell) {
                return;
            }
            
            if (moveIndexPath.item != ws.lastMoveIndexPath.item) {
                //这里未写数据，就没有数据交换
                [ws.collectionView moveItemAtIndexPath:ws.lastMoveIndexPath toIndexPath:moveIndexPath];
                
                ws.lastMoveIndexPath = moveIndexPath;
            }

        }
        
        if (longPress.state == UIGestureRecognizerStateEnded) {
            if (!ws.lastMoveIndexPath) {
                return;
            }
            UICollectionViewCell *endCell = [ws.collectionView cellForItemAtIndexPath:ws.lastMoveIndexPath];
            
            [ws.collectionView bringSubviewToFront:endCell];
            // 从当前的位置移动过去
            CGRect beginFrame = ws.snapImgView.frame;
            
            CGRect endFrame = endCell.frame;
            
            endCell.frame = beginFrame;
            
            ws.snapImgView.alpha = 0;
            
            endCell.alpha = 1;
            
            endCell.hidden = NO;
            
            [UIView animateWithDuration:0.3 animations:^{
                endCell.frame = endFrame;
            } completion:^(BOOL finished) {
                ws.lastMoveIndexPath = nil;
            }];
            
        }
        
    }];
    
    self.collectionView.dataSource = self;
    
    self.collectionView.delegate = self;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cov"];
    
    [self.view addSubview:self.collectionView];
    
}

- (CGFloat)waterflowLayout:(SXDragCollectionLayout *)waterflowLayout collectionView:(UICollectionView *)collectionView heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth {
    NSLog(@"%ld",[self.heightDB[indexPath.row] integerValue]);
    return [self.heightDB[indexPath.row] integerValue]; //瀑布流
//    return 100;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cov" forIndexPath:indexPath];
    int randomRed = arc4random() % 255;
    int randomGreen = arc4random() % 255;
    int randomBlue = arc4random() % 255;
    cell.contentView.backgroundColor = [UIColor colorWithRed:randomRed/255.0f green:randomGreen/255.0f blue:randomBlue/255.0f alpha:1];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
