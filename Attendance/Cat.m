//
//  Cat.m
//  Attendance
//
//  Created by heppokoact on 2012/09/17.
//
//

#import "Cat.h"

/**
 * 区分値・名称を管理するシングルトンクラス
 *
 */
@implementation Cat {
    NSDictionary * _catDict;
}

static Cat * _sharedInstance = nil;

/**
 * シングルトンインスタンスを取得する
 *
 * @return このクラスのシングルトンインスタンス
 */
+ (Cat *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Cat alloc]init];
    });
    return _sharedInstance;
}

/**
 * このクラスのインスタンスを作成し、初期化します
 */
- (id)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"Cat" ofType:@"plist"];
        _catDict = [[NSDictionary alloc]initWithContentsOfFile:path];
    }
    return self;
}

/**
 * 引数のキーに対応する辞書を取得します
 *
 * @param 取得する辞書のキー
 * @return キーに対応する辞書
 */
- (NSDictionary *) dictForKey:(NSString *)key {
    return [_catDict objectForKey:key];
}

/**
 * 引数のキーに対応するリストを取得します
 *
 * @param 取得するリストのキー
 * @return キーに対応するリスト
 */
- (NSArray *) arrayForKey: (NSString *)key {
    return [_catDict objectForKey:key];
}

@end
