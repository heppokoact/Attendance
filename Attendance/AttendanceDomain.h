//
//  AttendanceDomain.h
//  Attendance
//
//  Created by heppokoact on 2013/04/24.
//
//

#import <Foundation/Foundation.h>

/**
 * 出欠情報の取得に関するドメインオブジェクト
 */
@interface AttendanceDomain : NSObject

#pragma mark 出欠状況
@property BOOL attCatNone;
@property BOOL attCatNotYet;
@property BOOL attCatAtt;
@property BOOL attCatAbsence;
@property BOOL attCatTardy;
@property BOOL attCatEarlyLeaving;

#pragma mark 配布提出状況
@property BOOL itemCatNone;
@property BOOL handoutCatNotYet;
@property BOOL handoutCatDone;
@property BOOL rcptCatNotYet;
@property BOOL rcptCatDone;

#pragma mark プロジェクト・社員名・社員番号
@property NSString *projectName;
@property NSString *empName;
@property NSString *empNoStart;
@property NSString *empNoEnd;

@end
