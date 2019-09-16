//
//  AttendanceDao.h
//  Attendance
//
//  Created by heppokoact on 2013/04/24.
//
//

#import <Foundation/Foundation.h>
#import "Attendance.h"
#import "AttendanceDomain.h"

/**
 * 出欠情報にアクセスするためのDao
 */
@interface AttendanceDao : NSObject

/**
 * 引数の抽出条件に一致する出欠情報を取得します。
 * 
 * @params condition 抽出条件
 * @return 引数の抽出条件に一致する出欠情報のリスト
 */
- (NSArray *)findByConditions:(AttendanceDomain *)condition error:(NSError **)error;

/**
 * 引数の出欠情報を保存します。
 *
 * @params attendance 出欠情報
 */
- (void)update:(Attendance *)attendance error:(NSError **)error;

/**
 * プロジェクトの一覧を取得します。
 *
 * @return プロジェクトの一覧
 */
- (NSArray *)findAllProject:(NSError **)error;

@end
