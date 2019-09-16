//
//  Attendance.h
//  Attendance
//
//  Created by heppokoact on 2012/08/28.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Attendance : NSObject<NSCopying>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * attCat;
@property (nonatomic, retain) NSString * attribute;
@property (nonatomic, retain) NSString * dispCat;
@property (nonatomic, retain) NSString * empName;
@property (nonatomic, retain) NSString * empNo;
@property (nonatomic, retain) NSString * grpName;
@property (nonatomic, retain) NSString * handoutName;
@property (nonatomic, retain) NSString * handoutSitCat;
@property (nonatomic, retain) NSString * pjName;
@property (nonatomic, retain) NSString * postName;
@property (nonatomic, retain) NSString * rcptName;
@property (nonatomic, retain) NSString * rcptSitCat;
@property (nonatomic, retain) NSString * remCol;
@property (nonatomic, retain) NSNumber * seqNo;
@property (nonatomic, retain) NSDate * timeStamp;

@property (nonatomic, assign, readonly) NSDictionary * ATT_CAT_NAME;
@property (nonatomic, assign, readonly) NSDictionary * EXISTENCE_FLG_NAME;
@property (nonatomic, assign, readonly) NSDictionary * HANDOUT_SIT_CAT_NAME;
@property (nonatomic, assign, readonly) NSDictionary * RCPT_SIT_CAT_NAME;
@property (nonatomic, assign, readonly) NSDictionary * SIT_CAT_SHORT_NAME;


- (id)initWithDictionary:(NSDictionary *) dict;

- (NSString *)attCatName;
- (NSString *)handoutExistenceFlgName;
- (NSString *)handoutSitCatName;
- (NSString *)rcptExistenceFlgName;
- (NSString *)rcptSitCatName;
- (NSString *)sectionName;
- (NSString *)handoutSitCatNameShort;
- (NSString *)rcptSitCatNameShort;

- (BOOL)hasHandout;
- (BOOL)hasRcpt;

@end
