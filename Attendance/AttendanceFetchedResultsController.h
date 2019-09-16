//
//  AttendanceFetchedResultsController.h
//  Attendance
//
//  Created by heppokoact on 2013/02/11.
//
//

#import <CoreData/CoreData.h>

/**
 * MasterViewの表示データを管理するオブジェクトです。
 * セクションインデックスタイトルをデフォルトから変更するために、sectionIndexTitleForSectionNameをオーバーライドします。
 */
@interface AttendanceFetchedResultsController : NSFetchedResultsController

/*
 fetchedObjects.
 
 sections 戻り値はNSFetchedResultsSectionInfoの配列
 
 */
@end
