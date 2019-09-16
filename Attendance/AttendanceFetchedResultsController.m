//
//  AttendanceFetchedResultsController.m
//  Attendance
//
//  Created by heppokoact on 2013/02/11.
//
//

#import "AttendanceFetchedResultsController.h"

/**
 * MasterViewの表示データを管理するオブジェクトです。
 * セクションインデックスタイトルをデフォルトから変更するために、sectionIndexTitleForSectionNameをオーバーライドします。
 */
@implementation AttendanceFetchedResultsController

/**
 * セクションインデックスタイトルを返します。
 * セクション名をそのまま返します。
 *
 * @param sectionName セクション名
 * @return セクションインデックスタイトル
 */
- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName {
    ENTER_METHOD
    LEAVE_METHOD
    return sectionName;
}

@end
