//
//  MessageDelegate.h
//  Attendance
//
//  Created by heppokoact on 2013/05/06.
//
//

#import <Foundation/Foundation.h>

#define SITUATION_DISCARD_DETAIL @"SITUATION_DISCARD_DETAIL"
#define SITUATION_DISCARD_DETAIL_AT_SEARCH @"SITUATION_DISCARD_DETAIL_AT_SEARCH"
#define SITUATION_REMAIN_ITEM @"SITUATION_REMAIN_ITEM"
#define SITUATION_START_UPDATE_ATTENDANCE @"SITUATION_START_UPDATE_ATTENDANCE"
#define SITUATION_SUCCESS_UPDATE_ATTENDANCE @"SITUATION_END_UPDATE_ATTENDANCE"
#define SITUATION_START_GET_ATTENDANCES @"SITUATION_START_GET_ATTENDANCES"
#define SITUATION_SUCCESS_GET_ATTENDANCES @"SITUATION_SUCCESS_GET_ATTENDANCES"
#define SITUATION_ENTER_ATTENDANCE_CAT @"SITUATION_ENTER_ATTENDANCE_CAT"
#define SITUATION_ENTER_HANDOUT_CAT @"SITUATION_ENTER_HANDOUT_CAT"
#define SITUATION_ENTER_RCPT_CAT @"SITUATION_ENTER_RCPT_CAT"
#define SITUATION_PUSH_SUBMIT_BUTTON @"SITUATION_PUSH_SUBMIT_BUTTON"
#define SITUATION_CATCH_FAIRY @"SITUATION_CATCH_FAIRY"
#define SITUATION_VOID @"SITUATION_VOID"
#define SITUATION_ERROR @"SITUATION_ERROR"

/**
 * メッセージの表示を行うオブジェクトが実装すべきプロトコルです。
 */
@protocol MessageDelegate <NSObject>

@optional

/**
 * 現在のシチュエーションを取得します。
 *
 * @return 現在のシチュエーション
 */
- (NSString *)getCurrentSituation;

@required

/**
 * 引数の状況にひもづけられたメッセージを表示します。
 *
 * @param message メッセージ
 * @param situation 状況を表すキー
 * @param okBlock OKボタンを押下した時に実行するブロック
 * @param cancel キャンセルボタンを押下した時に実行するブロック
 */
- (void)showMessage:(NSString *) message at:(NSString *)situation okBlock:(BKBlock)okBlock cancelBlck:(BKBlock)cancelBlock;

@end
