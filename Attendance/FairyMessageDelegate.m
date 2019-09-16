//
//  FairyMessageDelegate.m
//  Attendance
//
//  Created by heppokoact on 2013/09/01.
//
//

#define FAIRY_MESSAGE_KEY @"message"
#define FAIRY_CONF_KEY @"conf"
#define FAIRY_OK_BLOCK_KEY @"okBlock"
#define FAIRY_CANCEL_BLOCK_KEY @"cancelBlock"
#define FAIRY_EMPTY_MESSAGE @""

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "FairyMessageDelegate.h"
#import "FairyMessage.h"
#import "DetailViewController.h"
#import "BubbleView.h"

@implementation FairyMessageDelegate {
    // 状況ごとに表示すべきメッセージとその表示方法を格納した辞書
    NSMutableDictionary *_messageDict;
    // 妖精と吹き出しを格納するコンテナビュー
    UIView *_containerView;
    // 妖精を表示するイメージビュー
    UIImageView *_imageView;
    // アニメーションパターン１（パタパタする）
    NSArray *_animationFlipFlap;
    // アニメーションパターン２（左向きと正面向きを繰り返す）
    NSArray *_animationLeftFront;
    // アニメーションパターン３（右向きと正面向きを繰り返す）
    NSArray *_animationRightFront;
    // 吹き出しのビュー
    BubbleView *_bubbleView;
    // レイヤーを表示中
    BOOL _layerOn;
    // 現在のメッセージ設定
    FairyMessage *_currentConf;
    // パン（ドラッグ）の検知オブジェクト
    UIPanGestureRecognizer *_panRecognizer;
}

- (NSString *)getCurrentSituation {
    return _currentConf.situation;
}

- (void)configureResource {
        _animationFlipFlap = @[
            [UIImage imageNamed:@"fairyPinkFront1.png"],
            [UIImage imageNamed:@"fairyPinkFront2.png"]
        ];
        _animationLeftFront = @[
            [UIImage imageNamed:@"fairyPinkFront1.png"],
            [UIImage imageNamed:@"fairyPinkLeft.png"]
        ];
        _animationRightFront = @[
            [UIImage imageNamed:@"fairyPinkFront1.png"],
            [UIImage imageNamed:@"fairyPinkRight.png"]
        ];
}

/**
 * このオブジェクトを初期化します。
 *
 * @return 初期化されたオブジェクト
 */
- (id)init {
    ENTER_METHOD
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGSize windowSize = delegate.window.frame.size;
    self = [super initWithFrame:CGRectMake(0, 0, windowSize.width, windowSize.height)];
    
    if (self) {
        [self configureResource];
        [self configureMessageDict];
        [delegate.window addSubview:self];
        
        _containerView = [[UIView alloc] initWithFrame:self.frame];
        [self addSubview:_containerView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        _imageView.center = self.center;
        _imageView.animationImages = _animationFlipFlap;
        _imageView.animationDuration = 2.0;
        _imageView.animationRepeatCount = 0;
        _imageView.userInteractionEnabled = YES;
        [_containerView addSubview:_imageView];
        [_imageView startAnimating];
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDragged:)];
        [_imageView addGestureRecognizer:_panRecognizer];
        
        _containerView.layer.position = CGPointMake(125, 100);
        _layerOn = NO;
        _currentConf = [_messageDict objectForKey:SITUATION_VOID];
    }
    
    LEAVE_METHOD
    
    return self;
}

/**
 * 状況ごとに表示すべきメッセージとその表示方法を格納した辞書を作成します。
 */
- (void)configureMessageDict {
    _messageDict = [NSMutableDictionary dictionary];
    
    // MasterViewで社員を選択した時にDetailViewの内容を破棄する警告
    FairyMessage *msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_OK_CANCEL;
    msg.definedPoint = FAIRY_DEFINED_POINT_CENTER;
    msg.moveToPoint = YES;
    msg.status = FAIRY_STATUS_FRONT;
    msg.bubbleDirection = PointDirectionRight;
    msg.layerType = FAIRY_LAYER_TYPE_ON;
    msg.titleStyle = BUBBLE_TITLE_STYLE_WARN;
    msg.title = @"警告";
    msg.situation = SITUATION_DISCARD_DETAIL;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // MasterViewで検索パネルを表示した時に表示する、検索時にDetailViewの内容を破棄する警告
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_OK;
    msg.definedPoint = FAIRY_DEFINED_POINT_CENTER;
    msg.moveToPoint = YES;
    msg.status = FAIRY_STATUS_FRONT;
    msg.bubbleDirection = PointDirectionRight;
    msg.layerType = FAIRY_LAYER_TYPE_ON;
    msg.titleStyle = BUBBLE_TITLE_STYLE_WARN;
    msg.title = @"警告";
    msg.situation = SITUATION_DISCARD_DETAIL_AT_SEARCH;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 確定ボタン押下時に提出物、配布物が残っていた時の警告
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_OK_CANCEL;
    msg.definedPoint = FAIRY_DEFINED_POINT_CENTER;
    msg.moveToPoint = YES;
    msg.status = FAIRY_STATUS_FRONT;
    msg.bubbleDirection = PointDirectionRight;
    msg.layerType = FAIRY_LAYER_TYPE_ON;
    msg.titleStyle = BUBBLE_TITLE_STYLE_WARN;
    msg.title = @"警告";
    msg.situation = SITUATION_REMAIN_ITEM;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 確定開始メッセージ
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = NO;
    msg.status = FAIRY_STATUS_FRONT;
    msg.bubbleDirection = PointDirectionLeftOrRight;
    msg.layerType = FAIRY_LAYER_TYPE_ON;
    msg.situation = SITUATION_START_UPDATE_ATTENDANCE;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 確定完了メッセージ
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = NO;
    msg.status = FAIRY_STATUS_FRONT;
    msg.bubbleDirection = PointDirectionLeftOrRight;
    msg.layerType = FAIRY_LAYER_TYPE_DELAY_OFF;
    msg.titleStyle = BUBBLE_TITLE_STYLE_INFO;
    msg.title = @"確定完了";
    msg.dismissInterval = 2.0;
    msg.situation = SITUATION_SUCCESS_UPDATE_ATTENDANCE;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 出欠情報一覧取得開始
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = NO;
    msg.status = FAIRY_STATUS_FRONT;
    msg.bubbleDirection = PointDirectionRight;
    msg.layerType = FAIRY_LAYER_TYPE_ON;
    msg.situation = SITUATION_START_GET_ATTENDANCES;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 出欠情報一覧取得完了
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = YES;
    msg.point = CGPointMake(345, 150);
    msg.status = FAIRY_STATUS_LEFT;
    msg.bubbleDirection = PointDirectionRight;
    msg.layerType = FAIRY_LAYER_TYPE_OFF;
    msg.situation = SITUATION_SUCCESS_GET_ATTENDANCES;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 出欠状態未選択
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = YES;
    msg.point = CGPointMake(310, 210);
    msg.status = FAIRY_STATUS_RIGHT;
    msg.bubbleDirection = PointDirectionLeft;
    msg.layerType = FAIRY_LAYER_TYPE_OFF;
    msg.situation = SITUATION_ENTER_ATTENDANCE_CAT;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 配布物未配布
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = YES;
    msg.point = CGPointMake(315, 340);
    msg.status = FAIRY_STATUS_RIGHT;
    msg.bubbleDirection = PointDirectionLeft;
    msg.layerType = FAIRY_LAYER_TYPE_OFF;
    msg.situation = SITUATION_ENTER_HANDOUT_CAT;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 提出物未提出
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = YES;
    msg.point = CGPointMake(315, 484);
    msg.status = FAIRY_STATUS_RIGHT;
    msg.bubbleDirection = PointDirectionLeft;
    msg.layerType = FAIRY_LAYER_TYPE_OFF;
    msg.situation = SITUATION_ENTER_RCPT_CAT;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 確定準備完了
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = YES;
    msg.point = CGPointMake(400, 803);
    msg.status = FAIRY_STATUS_RIGHT;
    msg.bubbleDirection = PointDirectionLeft;
    msg.layerType = FAIRY_LAYER_TYPE_OFF;
    msg.situation = SITUATION_PUSH_SUBMIT_BUTTON;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 捕獲中
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = NO;
    msg.status = FAIRY_STATUS_WRIGGLE;
    msg.bubbleDirection = PointDirectionRight;
    msg.layerType = FAIRY_LAYER_TYPE_OFF;
    msg.situation = SITUATION_CATCH_FAIRY;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // 無状態
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_NONE;
    msg.moveToPoint = NO;
    msg.status = FAIRY_STATUS_FRONT;
    msg.layerType = FAIRY_LAYER_TYPE_OFF;
    msg.situation = SITUATION_VOID;
    [_messageDict setObject:msg forKey:msg.situation];
    
    // エラー時
    msg = [[FairyMessage alloc] init];
    msg.dialogType = FAIRY_DIALOG_TYPE_OK;
    msg.definedPoint = FAIRY_DEFINED_POINT_CENTER;
    msg.moveToPoint = YES;
    msg.status = FAIRY_STATUS_FRONT;
    msg.bubbleDirection = PointDirectionRight;
    msg.layerType = FAIRY_LAYER_TYPE_ON;
    msg.titleStyle = BUBBLE_TITLE_STYLE_ERROR;
    msg.title = @"エラー";
    msg.situation = SITUATION_ERROR;
    [_messageDict setObject:msg forKey:msg.situation];
}

/**
 * 引数の状況にひもづけられたメッセージを表示します。
 *
 * @param message メッセージ
 * @param situationKey 状況を表すキー
 * @param okBlock OKボタンを押下した時に実行するブロック
 * @param cancel キャンセルボタンを押下した時に実行するブロック
 */
- (void)showMessage:(NSString *)message at:(NSString *)situation okBlock:(BKBlock)okBlock cancelBlck:(BKBlock)cancelBlock {
    ENTER_METHOD
    
    FairyMessage *conf = [_messageDict objectForKey:situation];
    FairyMessage *prevConf = _currentConf;
    _currentConf = conf;
    
    // レイヤーの表示/解除
    switch (conf.layerType) {
        case FAIRY_LAYER_TYPE_ON:
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            [self.superview bringSubviewToFront:self];
            _layerOn = YES;
            break;
        case FAIRY_LAYER_TYPE_DELAY_OFF: {
            BKTimerBlock delayOff = ^(NSTimeInterval interval) {
                self.backgroundColor = [UIColor clearColor];
                _layerOn = NO;
            };
            [NSTimer scheduledTimerWithTimeInterval:conf.dismissInterval
                                              block:delayOff
                                            repeats:NO];
            break;
        }
        case FAIRY_LAYER_TYPE_OFF:
            self.backgroundColor = [UIColor clearColor];
            _layerOn = NO;
            break;
    }
    
    // 妖精のアニメーションを変更
    if (_currentConf.status != prevConf.status) {
        switch (conf.status) {
            case FAIRY_STATUS_FRONT:
                _imageView.animationImages = _animationFlipFlap;
                _imageView.animationDuration = 2.0;
                break;
            case FAIRY_STATUS_LEFT:
                _imageView.animationImages = _animationLeftFront;
                _imageView.animationDuration = 2.0;
                break;
            case FAIRY_STATUS_RIGHT:
                _imageView.animationImages = _animationRightFront;
                _imageView.animationDuration = 2.0;
                break;
            case FAIRY_STATUS_WRIGGLE:
                _imageView.animationImages = _animationFlipFlap;
                _imageView.animationDuration = 0.1;
                break;
        }
        [_imageView startAnimating];
    }
    
    // 吹き出しの表示
    if (!_bubbleView || ![message isEqualToString:_bubbleView.message]) {
        if (_bubbleView) {
            [_bubbleView dismissAnimated:YES];
            _bubbleView = nil;
        }
        if (message && ![FAIRY_EMPTY_MESSAGE isEqualToString:message]) {
            _bubbleView = [[BubbleView alloc] initWithTitle:conf.title message:message];
            [_bubbleView setDialogType:conf.dialogType okBlock:okBlock cancelBlock:cancelBlock];
            [_bubbleView presentAtTarget:_imageView direction:conf.bubbleDirection];
            switch (conf.titleStyle) {
                case BUBBLE_TITLE_STYLE_NONE:
                    break;
                case BUBBLE_TITLE_STYLE_INFO:
                    _bubbleView.titleColor = [UIColor cyanColor];
                    break;
                case BUBBLE_TITLE_STYLE_WARN:
                    _bubbleView.titleColor = [UIColor yellowColor];
                    break;
                case BUBBLE_TITLE_STYLE_ERROR:
                    _bubbleView.titleColor = [UIColor redColor];
                    break;
            }
            if (conf.dismissInterval) {
                [_bubbleView autoDismissAnimated:YES atTimeInterval:conf.dismissInterval];
            }
        }
    }
    
    // 妖精の移動
    CGPoint start = _containerView.layer.position;
    CGPoint end = conf.point;
    if (FAIRY_DEFINED_POINT_CENTER == conf.definedPoint) {
        CGPoint center = self.center;
        CGFloat decreaseWidth = (_bubbleView.frame.size.width + _imageView.frame.size.width) / 2;
        end = CGPointMake(center.x - decreaseWidth, center.y);
    }
    if (conf.moveToPoint && !(start.x == end.x && start.y == end.y)) {
        start = ((CALayer *)_containerView.layer.presentationLayer).position;
        _panRecognizer.enabled = NO;
        _panRecognizer.enabled = YES;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.8;
        animation.calculationMode = kCAAnimationCubic;
        animation.delegate = self;
        UIBezierPath *path = [UIBezierPath bezierPath];
        //            CGFloat width = end.x - start.x;
        //            CGFloat height = end.y - start.y;
        CGPoint middle = CGPointMake((start.x + end.x) / 2, (start.y + end.y) / 2);
        CGPoint control1 = CGPointMake(randPosition(middle.x), randPosition(middle.y));
        CGPoint control2 = CGPointMake(randPosition(middle.x), randPosition(middle.y));
        [path moveToPoint:start];
        [path addCurveToPoint:end controlPoint1:control1 controlPoint2:control2];
        animation.path = path.CGPath;
        [_containerView.layer addAnimation:animation forKey:nil];
        _containerView.layer.position = end;
    }
    
    LEAVE_METHOD
}

- (void)dismissOldBubbleView {
    if (_bubbleView) {
        [_bubbleView dismissAnimated:YES];
        _bubbleView = nil;
    }
}

CGFloat randPosition(CGFloat number) {
    return number * (arc4random() % 150) / 100.0;
}

-(void)imageViewDragged:(UIPanGestureRecognizer *)sender {
    if (_currentConf.dialogType & FAIRY_DIALOG_TYPE_OK_CANCEL) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showMessage:@"きゃー" at:SITUATION_CATCH_FAIRY okBlock:nil cancelBlck:nil];
    } else if(sender.state == UIGestureRecognizerStateEnded) {
        [self showMessage:nil at:SITUATION_VOID okBlock:nil cancelBlck:nil];
    }
    
    CGPoint translation = [sender translationInView:_containerView];
    CGPoint center = _containerView.layer.position;
    _containerView.layer.position = CGPointMake(center.x + translation.x, center.y + translation.y);
    [sender setTranslation:CGPointZero inView:_containerView];
}

/**
 * このビューはイベントを背後のビューに透過させるが、
 * このビューに乗っているサブビューはイベントを処理するようにします。
 * また、レイヤー表示中はイベントを透過しないようにします。
 */
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *nowHitView = [super hitTest:point withEvent:event];
    if (!_layerOn && (self == nowHitView || _containerView == nowHitView)) {
        return nil;
    }
    return nowHitView;
}
@end
