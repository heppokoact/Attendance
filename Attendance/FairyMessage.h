//
//  FairyMessage.h
//  Attendance
//
//  Created by heppokoact on 2013/09/07.
//
//

#import <Foundation/Foundation.h>

/**
 * メッセージダイアログの種類
 */
typedef enum FairyDialogType : NSInteger {
    FAIRY_DIALOG_TYPE_NONE                = 1<<0,
    FAIRY_DIALOG_TYPE_OK                  = 1<<1,
    FAIRY_DIALOG_TYPE_CANCEL              = 1<<2,
    FAIRY_DIALOG_TYPE_OK_CANCEL           = FAIRY_DIALOG_TYPE_CANCEL | FAIRY_DIALOG_TYPE_OK,
} FairyDialogType;

typedef enum FairyDefinedPoint {
    FAIRY_DEFINED_POINT_CENTER            = 1,
} FairyDefinedPoint;

typedef enum FairyStatus : NSInteger {
    FAIRY_STATUS_LEFT                     = 1,
    FAIRY_STATUS_RIGHT                    = 2,
    FAIRY_STATUS_FRONT                    = 3,
    FAIRY_STATUS_WRIGGLE                  = 4,
} FairyStatus;

typedef enum PointDirection : NSInteger {
    PointDirectionAny = 0,
	PointDirectionLeft,
	PointDirectionRight,
	PointDirectionLeftOrRight,
} PointDirection;

typedef enum FairyLayerType : NSInteger {
    FAIRY_LAYER_TYPE_OFF                  = 1,
    FAIRY_LAYER_TYPE_ON                   = 2,
    FAIRY_LAYER_TYPE_DELAY_OFF            = 3,
} FairyLayerType;

typedef enum BubbleTitleStyle : NSInteger {
    BUBBLE_TITLE_STYLE_NONE               = 0,
    BUBBLE_TITLE_STYLE_INFO               = 1,
    BUBBLE_TITLE_STYLE_WARN               = 2,
    BUBBLE_TITLE_STYLE_ERROR              = 3,
} BubbleTitleStyle;

@interface FairyMessage : NSObject

@property FairyDialogType dialogType;
@property FairyDefinedPoint definedPoint;
@property CGPoint point;
@property BOOL moveToPoint;
@property FairyStatus status;
@property PointDirection bubbleDirection;
@property FairyLayerType layerType;
@property BubbleTitleStyle titleStyle;
@property NSString *title;
@property NSTimeInterval dismissInterval;
@property NSString *situation;

@end
