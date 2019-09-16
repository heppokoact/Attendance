//
//  BubbleView.m
//  Attendance
//
//  Created by heppokoact on 2013/09/01.
//
//

#import "BubbleView.h"
#import <QuartzCore/QuartzCore.h>

@interface BubbleView () {
	CGSize					_bubbleSize;
	CGFloat					_cornerRadius;
	BOOL					_highlight;
	PointDirection			_pointDirection;
	CGFloat					_pointerSize;
    CGFloat                 _margin;
    CGFloat                 _borderMargin;
    CGSize                  _buttonSize;
    FairyDialogType         _dialogType;
    BKBlock                 _okBlock;
    BKBlock                 _cancelBlock;
}

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) NSTimer *autoDismissTimer;
@property (nonatomic, strong) UIButton *dismissTarget;
@end


@implementation BubbleView

- (CGRect)bubbleFrame {
    return CGRectMake(0, 0, _bubbleSize.width, _bubbleSize.height);
}

- (CGRect)contentFrame {
    CGRect bubbleFrame = [self bubbleFrame];
    CGFloat pointerAdjust = 0;
    if (_pointDirection == PointDirectionRight) {
        pointerAdjust = _pointerSize;
    }
    CGRect contentFrame = CGRectMake(bubbleFrame.origin.x + _borderMargin + pointerAdjust,
                                     bubbleFrame.origin.y + _borderMargin,
                                     bubbleFrame.size.width - _borderMargin*2 - _pointerSize,
                                     bubbleFrame.size.height - _borderMargin*2);
    return contentFrame;
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);	// black
	CGContextSetLineWidth(c, self.borderWidth);
    
	CGMutablePathRef bubblePath = CGPathCreateMutable();
	
    CGFloat bw = _bubbleSize.width;
    CGFloat bh = _bubbleSize.height;
    
	if (_pointDirection == PointDirectionLeft) {
		CGPathMoveToPoint(bubblePath, NULL, bw, (bh / 2));
		CGPathAddLineToPoint(bubblePath, NULL, (bw - _pointerSize), ((bh + _pointerSize) / 2));
		
		CGPathAddArcToPoint(bubblePath, NULL,
							(bw - _pointerSize), bh,
							0, bh,
							_cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							0, bh,
							0, 0,
							_cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							0, 0,
							(bw - _pointerSize), 0,
							_cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							(bw - _pointerSize), 0,
							(bw - _pointerSize), bh,
							_cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, (bw - _pointerSize), ((bh - _pointerSize) / 2));
	} else {
		CGPathMoveToPoint(bubblePath, NULL, 0, (bh / 2));
		CGPathAddLineToPoint(bubblePath, NULL, _pointerSize, ((bh - _pointerSize) / 2));
		
		CGPathAddArcToPoint(bubblePath, NULL,
							_pointerSize, 0,
							bw, 0,
							_cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bw, 0,
							bw, bh,
							_cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bw, bh,
							_pointerSize, bh,
							_cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							_pointerSize, bh,
							_pointerSize, 0,
							_cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, _pointerSize, ((bh + _pointerSize) / 2));
	}
    
	CGPathCloseSubpath(bubblePath);
    
    CGContextSaveGState(c);
	CGContextAddPath(c, bubblePath);
	CGContextClip(c);
    
    if (self.hasGradientBackground == NO) {
        // Fill with solid color
        CGContextSetFillColorWithColor(c, [self.backgroundColor CGColor]);
        CGContextFillRect(c, self.bounds);
    }
    else {
        // Draw clipped background gradient
        CGFloat bubbleMiddle = 0.5;
        
        CGGradientRef myGradient;
        CGColorSpaceRef myColorSpace;
        size_t locationCount = 5;
        CGFloat locationList[] = {0.0, bubbleMiddle-0.03, bubbleMiddle, bubbleMiddle+0.03, 1.0};
        
        CGFloat colourHL = 0.0;
        if (_highlight) {
            colourHL = 0.25;
        }
        
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        int numComponents = CGColorGetNumberOfComponents([self.backgroundColor CGColor]);
        const CGFloat *components = CGColorGetComponents([self.backgroundColor CGColor]);
        if (numComponents == 2) {
            red = components[0];
            green = components[0];
            blue = components[0];
            alpha = components[1];
        }
        else {
            red = components[0];
            green = components[1];
            blue = components[2];
            alpha = components[3];
        }
        CGFloat colorList[] = {
            //red, green, blue, alpha
            red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
            red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
            red*1.08+colourHL, green*1.08+colourHL, blue*1.08+colourHL, alpha,
            red     +colourHL, green     +colourHL, blue     +colourHL, alpha,
            red     +colourHL, green     +colourHL, blue     +colourHL, alpha
        };
        myColorSpace = CGColorSpaceCreateDeviceRGB();
        myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList, locationList, locationCount);
        CGPoint startPoint, endPoint;
        startPoint.x = 0;
        startPoint.y = 0;
        endPoint.x = 0;
        endPoint.y = CGRectGetMaxY(self.bounds);
        
        CGContextDrawLinearGradient(c, myGradient, startPoint, endPoint,0);
        CGGradientRelease(myGradient);
        CGColorSpaceRelease(myColorSpace);
    }
	
    // Draw top highlight and bottom shadow
    if (self.has3DStyle) {
        CGContextSaveGState(c);
        CGMutablePathRef innerShadowPath = CGPathCreateMutable();
        
        // add a rect larger than the bounds of bubblePath
        CGPathAddRect(innerShadowPath, NULL, CGRectInset(CGPathGetPathBoundingBox(bubblePath), -30, -30));
        
        // add bubblePath to innershadow
        CGPathAddPath(innerShadowPath, NULL, bubblePath);
        CGPathCloseSubpath(innerShadowPath);
        
        // draw top highlight
        UIColor *highlightColor = [UIColor colorWithWhite:1.0 alpha:0.75];
        CGContextSetFillColorWithColor(c, highlightColor.CGColor);
        CGContextSetShadowWithColor(c, CGSizeMake(0.0, 4.0), 4.0, highlightColor.CGColor);
        CGContextAddPath(c, innerShadowPath);
        CGContextEOFillPath(c);
        
        // draw bottom shadow
        UIColor *shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        CGContextSetFillColorWithColor(c, shadowColor.CGColor);
        CGContextSetShadowWithColor(c, CGSizeMake(0.0, -4.0), 4.0, shadowColor.CGColor);
        CGContextAddPath(c, innerShadowPath);
        CGContextEOFillPath(c);
        
        CGPathRelease(innerShadowPath);
        CGContextRestoreGState(c);
    }
	
	CGContextRestoreGState(c);
    
    //Draw Border
    if (self.borderWidth > 0) {
        int numBorderComponents = CGColorGetNumberOfComponents([self.borderColor CGColor]);
        const CGFloat *borderComponents = CGColorGetComponents(self.borderColor.CGColor);
        CGFloat r, g, b, a;
        if (numBorderComponents == 2) {
            r = borderComponents[0];
            g = borderComponents[0];
            b = borderComponents[0];
            a = borderComponents[1];
        }
        else {
            r = borderComponents[0];
            g = borderComponents[1];
            b = borderComponents[2];
            a = borderComponents[3];
        }
        
        CGContextSetRGBStrokeColor(c, r, g, b, a);
        CGContextAddPath(c, bubblePath);
        CGContextDrawPath(c, kCGPathStroke);
    }
    
	CGPathRelease(bubblePath);
	
	// Draw title and text
    if (self.title) {
        [self.titleColor set];
        CGRect titleFrame = [self contentFrame];
        [self.title drawInRect:titleFrame
                      withFont:self.titleFont
                 lineBreakMode:UILineBreakModeClip
                     alignment:self.titleAlignment];
    }
	
	if (self.message) {
		[self.textColor set];
		CGRect textFrame = [self contentFrame];
        
        // Move down to make room for title
        if (self.title) {
            textFrame.origin.y += [self.title sizeWithFont:self.titleFont
                                         constrainedToSize:CGSizeMake(textFrame.size.width, 99999.0)
                                             lineBreakMode:UILineBreakModeClip].height;
            textFrame.origin.y += _margin;
        }
        
        [self.message drawInRect:textFrame
                        withFont:self.textFont
                   lineBreakMode:UILineBreakModeWordWrap
                       alignment:self.textAlignment];
    }
    
    if (_dialogType & FAIRY_DIALOG_TYPE_OK) {
        CGFloat buttonY = self.frame.size.height - _borderMargin - _buttonSize.height;
        CGFloat okButtonX;
        CGRect contentFrame = [self contentFrame];
        
        if (_dialogType & FAIRY_DIALOG_TYPE_CANCEL) {
            // OK
            okButtonX = (contentFrame.size.width - _margin) / 2 - _buttonSize.width + contentFrame.origin.x;
            // CANCEL
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_button.gif"] forState:UIControlStateNormal];
            [cancelButton setTitle:@"キャンセル" forState:UIControlStateNormal];
            CGFloat cancelButtonX = (contentFrame.size.width + _margin) / 2 + contentFrame.origin.x;
            cancelButton.frame = CGRectMake(cancelButtonX, buttonY, _buttonSize.width, _buttonSize.height);
            [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelButton];
            
        } else {
            // OK
            okButtonX = (contentFrame.size.width - _buttonSize.width) / 2 + contentFrame.origin.x;
        }
        
        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [okButton setBackgroundImage:[UIImage imageNamed:@"ok_button.gif"] forState:UIControlStateNormal];
        [okButton setTitle:@"ＯＫ" forState:UIControlStateNormal];
        okButton.frame = CGRectMake(okButtonX, buttonY, _buttonSize.width, _buttonSize.height);
        [okButton addTarget:self action:@selector(okButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:okButton];
    }
}

- (void)presentAtTarget:(UIView *)target direction:(PointDirection)dir {
    self.targetView = target;
    if (PointDirectionLeftOrRight == dir) {
        CGFloat absoluteTargetX = [target.superview convertPoint:target.center toView:nil].x;
        CGFloat halfScreenWidth = [UIScreen mainScreen].bounds.size.width / 2;
        NSLog(@"%f : %f", absoluteTargetX, halfScreenWidth);
        _pointDirection = (absoluteTargetX < halfScreenWidth) ? PointDirectionRight : PointDirectionLeft;
    } else {
        _pointDirection = dir;
    }
    
    // If we want to dismiss the bubble when the user taps anywhere, we need to insert
    // an invisible button over the background.
    if ( self.dismissTapAnywhere ) {
        self.dismissTarget = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.dismissTarget addTarget:self action:@selector(dismissTapAnywhereFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.dismissTarget setTitle:@"" forState:UIControlStateNormal];
        self.dismissTarget.frame = self.bounds;
        [target.superview addSubview:self.dismissTarget];
    }
    
    [target.superview addSubview:self];
	
	// Size of rounded rect
	CGSize textSize = CGSizeZero;
    
    if (self.message!=nil) {
        textSize= [self.message sizeWithFont:self.textFont
                           constrainedToSize:CGSizeMake(self.maxWidth, 99999.0)
                               lineBreakMode:UILineBreakModeWordWrap];
    }
    CGFloat titleHight = 0;
    if (self.title != nil) {
        titleHight = [self.title sizeWithFont:self.titleFont
                            constrainedToSize:CGSizeMake(self.maxWidth, 99999.0)
                                lineBreakMode:UILineBreakModeClip].height;
        titleHight += _margin;
    }
    CGFloat buttonWidth = 0;
    CGFloat buttonHight = 0;
    if (_dialogType & FAIRY_DIALOG_TYPE_OK) {
        buttonWidth = _buttonSize.width;
        buttonHight = _buttonSize.height + _margin;
        if (_dialogType & FAIRY_DIALOG_TYPE_CANCEL) {
            buttonWidth += _buttonSize.width + _margin;
        }
    }
    if (textSize.height > self.maxHeight) {
        CGFloat pointerAdjust = 0;
        if (_pointDirection == PointDirectionRight) {
            pointerAdjust = _pointerSize;
        }
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(_borderMargin + pointerAdjust,
                                                                            _borderMargin + titleHight,
                                                                            self.maxWidth,
                                                                            self.maxHeight - titleHight - buttonHight)];
        textView.text = self.message;
        self.message = nil;
        textView.scrollEnabled = YES;
        textView.editable = NO;
        textView.clipsToBounds = YES;
        textView.font = [UIFont systemFontOfSize:15.0];
        textView.layer.cornerRadius = 5;
        [textView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
        [textView.layer setBorderWidth:2.0];
        textView.frame = textView.frame;
        self.customView = textView;
        [self addSubview:textView];
    }
    if (self.customView != nil) {
        textSize = self.customView.frame.size;
    }
    
    textSize.height += titleHight;
    textSize.height += buttonHight;
    if (textSize.width < buttonWidth) {
        textSize.width = buttonWidth;
    }
    
	_bubbleSize = CGSizeMake(textSize.width + _borderMargin*2 + _pointerSize, textSize.height + _borderMargin*2);
    CGPoint origin;
    if (_pointDirection == PointDirectionLeft) {
        origin.x = -1 * (_bubbleSize.width + _margin) + target.frame.origin.x;
        origin.y = (target.frame.size.height - _bubbleSize.height) / 2 + target.frame.origin.y;
    } else {
        origin.x = target.frame.size.width + _margin + target.frame.origin.x;
        origin.y = (target.frame.size.height - _bubbleSize.height) / 2 + target.frame.origin.y;
    }
    CGRect frame = CGRectMake(origin.x, origin.y, _bubbleSize.width, _bubbleSize.height);
	
    [self setNeedsDisplay];
    self.frame = frame;
}

- (void)finaliseDismiss {
	[self.autoDismissTimer invalidate]; self.autoDismissTimer = nil;
    
    if (self.dismissTarget) {
        [self.dismissTarget removeFromSuperview];
		self.dismissTarget = nil;
    }
	
	[self removeFromSuperview];
    
	_highlight = NO;
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self finaliseDismiss];
}

- (void)dismissAnimated:(BOOL)animated {
	
	if (animated) {
		CGRect frame = self.frame;
		frame.origin.y += 10.0;
		
		[UIView beginAnimations:nil context:nil];
		self.alpha = 0.0;
		self.frame = frame;
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else {
		[self finaliseDismiss];
	}
}

- (void)autoDismissAnimatedDidFire:(NSTimer *)theTimer {
    NSNumber *animated = [[theTimer userInfo] objectForKey:@"animated"];
    [self dismissAnimated:[animated boolValue]];
	[self notifyDelegatePopTipViewWasDismissedByUser];
}

- (void)autoDismissAnimated:(BOOL)animated atTimeInterval:(NSTimeInterval)timeInvertal {
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:timeInvertal
															 target:self
														   selector:@selector(autoDismissAnimatedDidFire:)
														   userInfo:userInfo
															repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.autoDismissTimer forMode:NSRunLoopCommonModes];
}

- (void)notifyDelegatePopTipViewWasDismissedByUser {
	__strong id<BubbleViewDelegate> delegate = self.delegate;
	[delegate popTipViewWasDismissedByUser:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.disableTapToDismiss) {
		[super touchesBegan:touches withEvent:event];
		return;
	}
    
	[self dismissByUser];
}

- (void)dismissTapAnywhereFired:(UIButton *)button
{
	[self dismissByUser];
}

- (void)dismissByUser
{
	_highlight = YES;
	[self setNeedsDisplay];
	
	[self dismissAnimated:YES];
	
	[self notifyDelegatePopTipViewWasDismissedByUser];
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // at the end set to normal size
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)setDialogType:(FairyDialogType)dialogType okBlock:(BKBlock)okBlock cancelBlock:(BKBlock)cancelBlock {
    _dialogType = dialogType;
    _okBlock = okBlock;
    _cancelBlock = cancelBlock;
}

- (void)okButtonTapped:(id) sender {
    if (_okBlock) {
        _okBlock();
    }
    [self dismissAnimated:YES];
}

- (void)cancelButtonTapped:(id) sender {
    if (_cancelBlock) {
        _cancelBlock();
    }
    [self dismissAnimated:YES];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
		
		_cornerRadius = 10.0;
		_pointerSize = 12.0;
        _margin = 10.0;
        _borderMargin = 14.0;
		_buttonSize = CGSizeMake(100.0, 40.0);
        _dialogType = FAIRY_DIALOG_TYPE_NONE;
        
        self.borderWidth = 1.0;
		self.textFont = [UIFont systemFontOfSize:16.0];
		self.textColor = [UIColor whiteColor];
		self.textAlignment = UITextAlignmentCenter;
		self.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:128.0/255.0 alpha:0.8];
        self.has3DStyle = YES;
        self.borderColor = [UIColor blackColor];
        self.hasShadow = YES;
        self.disableTapToDismiss = YES;
        self.dismissTapAnywhere = NO;
        self.preferredPointDirection = PointDirectionAny;
        self.hasGradientBackground = NO;
        self.userInteractionEnabled = YES;
        self.maxWidth = 250;
        self.maxHeight = 400;
    }
    return self;
}

- (void)setHasShadow:(BOOL)newHasShadow {
    if (newHasShadow) {
        self.layer.shadowOffset = CGSizeMake(0, 3);
        self.layer.shadowRadius = 2.0;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 0.3;
    } else {
        self.layer.shadowOpacity = 0.0;
    }
}

- (PointDirection) getPointDirection {
    return _pointDirection;
}

- (id)initWithTitle:(NSString *)titleToShow message:(NSString *)messageToShow {
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
        self.title = titleToShow;
		self.message = messageToShow;
        
        self.titleFont = [UIFont boldSystemFontOfSize:20.0];
        self.titleColor = [UIColor redColor];
        self.titleAlignment = UITextAlignmentCenter;
	}
	return self;
}

- (id)initWithMessage:(NSString *)messageToShow {
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.message = messageToShow;
	}
	return self;
}

- (id)initWithCustomView:(UIView *)aView {
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.customView = aView;
        [self addSubview:self.customView];
	}
	return self;
}

@end