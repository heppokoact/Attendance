//
//  Message.h
//  Attendance
//
//  Created by heppokoact on 2013/05/06.
//
//

#import <Foundation/Foundation.h>

/**
 * メッセージダイアログの種類
 */
typedef enum DialogType : NSInteger {
    DIALOG_TYPE_NONE                = 1<<0,
    DIALOG_TYPE_OK                  = 1<<1,
    DIALOG_TYPE_CANCEL              = 1<<2,
    DIALOG_TYPE_OK_CANCEL           = DIALOG_TYPE_CANCEL | DIALOG_TYPE_OK,
    DIALOG_TYPE_SHOW_PROGRESS       = 1<<3,
    DIALOG_TYPE_DISMISS_PROGRESS    = 1<<4,
    DIALOG_TYPE_SUCCESS_PROGRESS    = 1<<5
} DialogType;

@interface Message : NSObject

@property DialogType dialogType;
@property NSString *title;

@end
