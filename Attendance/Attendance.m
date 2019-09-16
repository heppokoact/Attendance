//
//  Attendance.m
//  Attendance
//
//  Created by heppokoact on 2012/08/28.
//
//

#import "AppDelegate.h"
#import "Attendance.h"
#import "Cat.h"

@implementation Attendance

- (NSDictionary *)ATT_CAT_NAME {
    return [[Cat sharedInstance]dictForKey:@"attCat"];
}

- (NSDictionary *)EXISTENCE_FLG_NAME {
    return [[Cat sharedInstance]dictForKey:@"existenceFlg"];
}

- (NSDictionary *)HANDOUT_SIT_CAT_NAME {
    return [[Cat sharedInstance]dictForKey:@"handoutSitCat"];
}

- (NSDictionary *)RCPT_SIT_CAT_NAME {
    return [[Cat sharedInstance]dictForKey:@"rcptSitCat"];
}

- (NSDictionary *)SIT_CAT_SHORT_NAME {
    return [[Cat sharedInstance]dictForKey:@"sitCatShort"];
}

- (NSString *)attCatName {
    return [self.ATT_CAT_NAME objectForKey:self.attCat];
}

- (NSString *)handoutExistenceFlgName {
    NSString *existence = (!self.handoutName || [self.handoutName length] == 0) ? @"0" : @"1";
    return [self.EXISTENCE_FLG_NAME objectForKey:existence];
}

- (NSString *)handoutSitCatName {
    return [self.HANDOUT_SIT_CAT_NAME objectForKey:self.handoutSitCat];
}

- (NSString *)rcptExistenceFlgName {
    NSString *existence = (!self.rcptName || [self.rcptName length] == 0) ? @"0" : @"1";
    return [self.EXISTENCE_FLG_NAME objectForKey:existence];
}

- (NSString *)rcptSitCatName {
    return [self.RCPT_SIT_CAT_NAME objectForKey:self.rcptSitCat];
}

- (NSString *)handoutSitCatNameShort {
    return [self.SIT_CAT_SHORT_NAME objectForKey:self.handoutSitCat];
}

- (NSString *)rcptSitCatNameShort {
    return [self.SIT_CAT_SHORT_NAME objectForKey:self.rcptSitCat];
}

/**
 * 引数の辞書から出欠情報を取得してAttendanceインスタンスを生成します。
 *
 * @param dict 出欠情報を保持した辞書
 * @return Attendanceインスタンス
 */
- (id)initWithDictionary:(NSDictionary *) dict {
    ENTER_METHOD
    
    Attendance *att = [self init];
    
    if (att) {
        att.id = [dict objectForKey:@"id"];
        att.attCat = [dict objectForKey:@"attCat"];
        att.attribute = [dict objectForKey:@"attribute"];
        att.dispCat = [dict objectForKey:@"dispCat"];
        att.empName = [dict objectForKey:@"empName"];
        att.empNo = [dict objectForKey:@"empNo"];
        att.grpName = [dict objectForKey:@"grpName"];
        att.handoutName = [dict objectForKey:@"handoutName"];
        att.handoutSitCat = [dict objectForKey:@"handoutSitCat"];
        att.pjName = [dict objectForKey:@"pjName"];
        att.postName = [dict objectForKey:@"postName"];
        att.rcptName = [dict objectForKey:@"rcptName"];
        att.rcptSitCat = [dict objectForKey:@"rcptSitCat"];
        att.remCol = [dict objectForKey:@"remCol"];
        att.seqNo = [dict objectForKey:@"seqNo"];
        // timeStampは文字列からの変換が必要
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = TIMESTAMP_FORMAT;
        NSString * timeStamp = [dict objectForKey:@"timeStamp"];
        att.timeStamp = [formatter dateFromString:timeStamp];
    }
    
    LEAVE_METHOD
    
    return att;
}

/**
 * MasterViewControllerで使用するセルの所属セクションを返します。
 * 所属セクションは社員Noを200刻みで刻んだものになります。
 * 
 * @return 所属セクション
 */
- (NSString *)sectionName {
    ENTER_METHOD
    
    int intEmpNo = [self.empNo intValue];
    int indexString = intEmpNo / 100 * 100;
    NSString *name = [NSString stringWithFormat:@"%05d", indexString];
    
    LEAVE_METHOD
    
    return name;
}

/**
 * このインスタンスをコピーします（shallow copy）
 *
 * @param zone メモリのゾーン
 * @return このインスタンスのコピー
 */
- (id)copyWithZone:(NSZone *)zone {
    ENTER_METHOD
    
    Attendance *clone = [[Attendance alloc] init];
    clone.id = self.id;
    clone.attCat = self.attCat;
    clone.attribute = self.attribute;
    clone.dispCat = self.dispCat;
    clone.empName = self.empName;
    clone.empNo = self.empNo;
    clone.grpName = self.grpName;
    clone.handoutName = self.handoutName;
    clone.handoutSitCat = self.handoutSitCat;
    clone.pjName = self.pjName;
    clone.postName = self.postName;
    clone.rcptName = self.rcptName;
    clone.rcptSitCat = self.rcptSitCat;
    clone.remCol = self.remCol;
    clone.seqNo = self.seqNo;
    clone.timeStamp = self.timeStamp;
    
    LEAVE_METHOD
    
    return clone;
}

/**
 * このインスタンスと引数のインスタンスの内容が等価かどうかを調べます。
 *
 * @param object 比較対象
 * @return 等価ならtrue
 */
- (BOOL)isEqual:(id)object {
    ENTER_METHOD
    
    if (!object) {
        return NO;
    }
    
    // Attendance型でなければfalse
    if (![object isKindOfClass:[Attendance class]]) {
        return NO;
    }
    
    // 内容の比較をする
    Attendance *that = (Attendance *) object;
    BOOL result =
        [self isEqualA: self.id andB:that.id] &&
        [self isEqualA: self.attCat andB: that.attCat] &&
        [self isEqualA: self.attribute andB: that.attribute] &&
        [self isEqualA: self.dispCat andB: that.dispCat] &&
        [self isEqualA: self.empName andB: that.empName] &&
        [self isEqualA: self.empNo andB: that.empNo] &&
        [self isEqualA: self.grpName andB: that.grpName] &&
        [self isEqualA: self.handoutName andB: that.handoutName] &&
        [self isEqualA: self.handoutSitCat andB: that.handoutSitCat] &&
        [self isEqualA: self.pjName andB: that.pjName] &&
        [self isEqualA: self.postName andB: that.postName] &&
        [self isEqualA: self.rcptName andB: that.rcptName] &&
        [self isEqualA: self.rcptSitCat andB: that.rcptSitCat] &&
        [self isEqualA: self.remCol andB: that.remCol] &&
        [self isEqualA: self.seqNo andB: that.seqNo] &&
        [self isEqualA: self.timeStamp andB: that.timeStamp];
    
    LEAVE_METHOD
    
    return result;
}

/**
 * 引数の２つのインスタンスが等しいかどうかを調べます。
 *
 * @param a 比較対象A
 * @param b 比較対象B
 * @return 等しければtrue
 */
- (BOOL)isEqualA:(id)a andB:(id)b {
    ENTER_METHOD
    
    BOOL result = (a == nil && b == nil) || [a isEqual:b];
    
    LEAVE_METHOD
    
    return result;
}

/**
 * このインスタンスのハッシュ値を取得します。
 *
 * @return このインスタンスのハッシュ値
 */
- (NSUInteger)hash {
    ENTER_METHOD
    
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.id hash];
    result = prime * result + [self.attCat hash];
    result = prime * result + [self.attribute hash];
    result = prime * result + [self.dispCat hash];
    result = prime * result + [self.empName hash];
    result = prime * result + [self.empNo hash];
    result = prime * result + [self.grpName hash];
    result = prime * result + [self.handoutName hash];
    result = prime * result + [self.handoutSitCat hash];
    result = prime * result + [self.pjName hash];
    result = prime * result + [self.postName hash];
    result = prime * result + [self.rcptName hash];
    result = prime * result + [self.rcptSitCat hash];
    result = prime * result + [self.remCol hash];
    result = prime * result + [self.seqNo hash];
    result = prime * result + [self.timeStamp hash];
    
    LEAVE_METHOD
    
    return  result;
}

/**
 * 配布物があるかどうかを返します。
 *
 * @return 配布物がある場合はtrue
 */
- (BOOL)hasHandout {
    ENTER_METHOD
    
    BOOL result = self.handoutName && self.handoutName.length > 0;
    
    LEAVE_METHOD
    
    return result;
}

/**
 * 提出物があるかどうかを返します。
 *
 * @return 提出物がある場合はtrue
 */
- (BOOL)hasRcpt {
    ENTER_METHOD
    
    BOOL result = self.rcptName && self.rcptName.length > 0;
    
    LEAVE_METHOD
    
    return result;
}

@end
