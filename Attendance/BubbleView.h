//
//  BubbleView.h
//  Attendance
//
//  Created by heppokoact on 2013/09/01.
//
//

#import <UIKit/UIKit.h>
#import "FairyMessage.h"

@protocol BubbleViewDelegate;

@interface BubbleView : UIView

@property (nonatomic, strong)			UIColor					*backgroundColor;
@property (nonatomic, weak)				id<BubbleViewDelegate>	delegate;
@property (nonatomic, assign)			BOOL					disableTapToDismiss;
@property (nonatomic, assign)			BOOL					dismissTapAnywhere;
@property (nonatomic, strong)			NSString				*title;
@property (nonatomic, strong)			NSString				*message;
@property (nonatomic, strong)           UIView	                *customView;
@property (nonatomic, strong)			UIColor					*titleColor;
@property (nonatomic, strong)			UIFont					*titleFont;
@property (nonatomic, strong)			UIColor					*textColor;
@property (nonatomic, strong)			UIFont					*textFont;
@property (nonatomic, assign)			UITextAlignment			titleAlignment;
@property (nonatomic, assign)			UITextAlignment			textAlignment;
@property (nonatomic, assign)           BOOL                    has3DStyle;
@property (nonatomic, strong)			UIColor					*borderColor;
@property (nonatomic, assign)			CGFloat					borderWidth;
@property (nonatomic, assign)           BOOL                    hasShadow;
@property (nonatomic, assign)           CGFloat                 maxWidth;
@property (nonatomic, assign)           CGFloat                 maxHeight;
@property (nonatomic, assign)           PointDirection          preferredPointDirection;
@property (nonatomic, assign)           BOOL                    hasGradientBackground;


/* Contents can be either a message or a UIView */
- (id)initWithTitle:(NSString *)titleToShow message:(NSString *)messageToShow;
- (id)initWithMessage:(NSString *)messageToShow;
- (id)initWithCustomView:(UIView *)aView;

- (void)presentAtTarget:(UIView *)target direction:(PointDirection)dir;
- (void)dismissAnimated:(BOOL)animated;
- (void)autoDismissAnimated:(BOOL)animated atTimeInterval:(NSTimeInterval)timeInvertal;
- (PointDirection) getPointDirection;
- (void)setDialogType:(FairyDialogType)dialogType okBlock:(BKBlock)okBlock cancelBlock:(BKBlock)cancelBlock;

@end


@protocol BubbleViewDelegate <NSObject>
- (void)popTipViewWasDismissedByUser:(BubbleView *)popTipView;
@end
