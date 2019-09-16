//
//  AlertViewMessageDelegate.m
//  Attendance
//
//  Created by heppokoact on 2013/05/06.
//
//

#import "AlertViewMessageDelegate.h"
#import "MessageDelegate.h"
#import "Message.h"
#import "SVProgressHUD.h"

/**
 * UIAlertViewを使用してメッセージの表示を行うMessageDelegateです。
 */
@implementation AlertViewMessageDelegate {
    // 状況ごとに表示すべきメッセージとその表示方法を格納した辞書
    NSMutableDictionary *_messageDict;
}

/**
 * このオブジェクトを初期化します。
 *
 * @return 初期化されたオブジェクト
 */
- (id)init {
    ENTER_METHOD
    
    self = [super init];
    
    if (self) {
        _messageDict = [NSMutableDictionary dictionary];
        
        // MasterViewで社員を選択した時にDetailViewの内容を破棄する警告
        Message *msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_OK_CANCEL;
        msg.title = @"警告";
        [_messageDict setObject:msg forKey:SITUATION_DISCARD_DETAIL];
        
        // MasterViewで検索パネルを表示した時に表示する、検索時にDetailViewの内容を破棄する警告
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_OK;
        msg.title = @"警告";
        [_messageDict setObject:msg forKey:SITUATION_DISCARD_DETAIL_AT_SEARCH];
        
        // 確定ボタン押下時に提出物、配布物が残っていた時の警告
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_OK_CANCEL;
        msg.title = @"警告";
        [_messageDict setObject:msg forKey:SITUATION_REMAIN_ITEM];
        
        // 確定開始メッセージ
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_SHOW_PROGRESS;
        [_messageDict setObject:msg forKey:SITUATION_START_UPDATE_ATTENDANCE];
        
        // 確定完了メッセージ
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_SUCCESS_PROGRESS;
        [_messageDict setObject:msg forKey:SITUATION_SUCCESS_UPDATE_ATTENDANCE];
        
        // 確定時のエラー
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_OK | DIALOG_TYPE_DISMISS_PROGRESS;
        msg.title = @"エラー";
        [_messageDict setObject:msg forKey:SITUATION_ERROR];
        
        // 出欠情報一覧取開始
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_SHOW_PROGRESS;
        [_messageDict setObject:msg forKey:SITUATION_START_GET_ATTENDANCES];
        
        // 出欠情報一覧取開始
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_DISMISS_PROGRESS;
        [_messageDict setObject:msg forKey:SITUATION_SUCCESS_GET_ATTENDANCES];
        
        // 出欠情報一覧取得時のエラー
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_OK | DIALOG_TYPE_DISMISS_PROGRESS;
        msg.title = @"エラー";
        [_messageDict setObject:msg forKey:SITUATION_ERROR];
        
        // プロジェクト一覧取得時のエラー
        msg = [[Message alloc] init];
        msg.dialogType = DIALOG_TYPE_OK;
        msg.title = @"エラー";
        [_messageDict setObject:msg forKey:SITUATION_ERROR];
    }
    
    LEAVE_METHOD
    
    return self;
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
    
    Message *msg = [_messageDict objectForKey:situation];
    NSInteger dialogType = msg.dialogType;
    
    // SVProgressHUDを使用する場合（レイヤー解除）
    if (dialogType & DIALOG_TYPE_DISMISS_PROGRESS) {
        [SVProgressHUD dismiss];
    }
    
    // SVProgressHUDを使用する場合（処理成功メッセージを表示してレイヤー解除）
    if (dialogType & DIALOG_TYPE_SUCCESS_PROGRESS) {
        [SVProgressHUD showSuccessWithStatus:message];
    }
    
    // UIAlertViewを使用する場合
    if (dialogType & DIALOG_TYPE_OK) {
        UIAlertView *alert = [UIAlertView alertViewWithTitle:msg.title message:message];
        [alert addButtonWithTitle:@"OK" handler:okBlock];
        if (dialogType & DIALOG_TYPE_CANCEL) {
            [alert addButtonWithTitle:@"キャンセル" handler:cancelBlock];
        }
        [alert show];
    }
    
    // SVProgressHUDを使用する場合（レイヤー表示）
    if (dialogType & DIALOG_TYPE_SHOW_PROGRESS) {
        [self performSelectorInBackground:@selector(showProgress:) withObject:message];
    }
    LEAVE_METHOD
}

/**
 * SVProgressHUDを使用してメッセージを表示します。
 * SVProgressHUDによるレイヤーの表示は別スレッドで行う必要が有るため、selectorに指定できるよう処理を分離しています。
 *
 * @param message 表示するメッセージ
 */
- (void)showProgress:(NSString *)message {
    ENTER_METHOD
    
    @autoreleasepool {
        [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
    }
    
    LEAVE_METHOD
}

@end
