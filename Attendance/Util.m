//
//  Util.m
//  Attendance
//
//  Created by heppokoact on 2013/08/07.
//
//

#import "AppDelegate.h"
#import "Util.h"

@implementation Util

/**
 * 引数の文字列のURLエンコードを行います。
 *
 * @param str URLエンコード対象
 * @return URLエンコード済みの文字列
 */
+ (NSString *)urlEncode:(NSString *) str {
    ENTER_METHOD
    
    NSString *encoded = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                              NULL,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8 );
    LEAVE_METHOD
    
    return encoded;
}

/**
 * ユーザー表示用にエラーメッセージの組立を行います。
 *
 * @param message エラーメッセージ
 * @param error エラーオブジェクト
 * @return 組立済みエラーメッセージ
 */
+ (NSString *)buildErrorMessage:(NSString *)message error:(NSError *)error {
    ENTER_METHOD
    
    NSDate *date = [NSDate date];
    NSString *result = [NSString stringWithFormat:@"%@\n\nDate: %@\nErrorCode: %d\nDomain: %@\n%@", message, date, error.code, error.domain, error.userInfo];
    
    LEAVE_METHOD
    
    return result;
}

/**
 * 引数のコンテキストぱすからの相対URLを絶対URLに変換します。
 * コンテキストパスはユーザーデフォルトから取得します。
 * コンテキストパスが取得できない場合はNULLを返します。
 *
 * @return 絶対URL
 */
+ (NSString *)toAbsoluteUrl:(NSString *)url {
    ENTER_METHOD
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *contextPath = [ud objectForKey:UD_KEY_ATTENDANCE_SERVER_URL];
    
    NSString *result = NULL;
    if (contextPath) {
        result = [NSString stringWithFormat:@"%@%@", contextPath, url];
    }
    
    LEAVE_METHOD
    
    return result;
}

@end
