//
//  Util.h
//  Attendance
//
//  Created by heppokoact on 2013/08/07.
//
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

/**
 * 引数の文字列のURLエンコードを行います。
 *
 * @param str URLエンコード対象
 * @return URLエンコード済みの文字列
 */
+ (NSString *)urlEncode:(NSString *) str;

/**
 * ユーザー表示用にエラーメッセージの組立を行います。
 *
 * @param message エラーメッセージ
 * @param error エラーオブジェクト
 * @return 組立済みエラーメッセージ
 */
+ (NSString *)buildErrorMessage:(NSString *)message error:(NSError *)error;

/**
 * 引数のコンテキストぱすからの相対URLを絶対URLに変換します。
 * コンテキストパスはユーザーデフォルトから取得します。
 *
 * @return 絶対URL
 */
+ (NSString *)toAbsoluteUrl:(NSString *)url;
    
@end
