//
//  AttendanceDao.m
//  Attendance
//
//  Created by heppokoact on 2013/04/24.
//
//

#import "AppDelegate.h"
#import "AttendanceDao.h"
#import "Util.h"

/**
 * 出欠情報にアクセスするためのDao
 */
@implementation AttendanceDao {
    // AppDelegate
    AppDelegate *_delegate;
}

/**
 * このインスタンスの初期化を行います。
 */
- (id)init {
    self = [super init];
    if (self) {
        _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

/**
 * 引数の抽出条件に一致する出欠情報を取得します。
 *
 * @params condition 抽出条件
 * @return 引数の抽出条件に一致する出欠情報のリスト
 */
- (NSArray *)findByConditions:(AttendanceDomain *)condition error:(NSError **)error {
    ENTER_METHOD
    
    // リクエストの作成
    NSString *url = [Util toAbsoluteUrl:@"/attendance"];
    if (!url) {
        *error = [[NSError alloc] initWithDomain:ERROR_DOMAIN_ATTENDANCE
                                            code:ERROR_CODE_UNKNOWN
                                        userInfo:@{@"Solvent" : @"Please setup Attendance Server."}];
        return @[];
    }
    url = [url stringByAppendingString:[self makeQueryString:condition]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = 5;
    
    // リクエストの実行
    NSError *requestError = nil;
    NSData *jsonRawData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
    if (requestError) {
        [_delegate outputErrorLog:requestError forKey:@"findByConditions#request"];
        *error = requestError;
        return @[];
    }
    
    // 取得した出欠情報（JSON）をパースしてAttendanceインスタンスを生成
    NSError *jsonError = nil;
    NSArray *jsonAttndances = [NSJSONSerialization JSONObjectWithData:jsonRawData options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError) {
        [_delegate outputErrorLog:jsonError forKey:@"findByConditions#json"];
        *error = jsonError;
        return @[];
    }
    NSMutableArray * attendances = [NSMutableArray array];
    for (NSDictionary *dict in jsonAttndances) {
        [attendances addObject:[[Attendance alloc] initWithDictionary:dict]];
    }
    
    LEAVE_METHOD
    
    return attendances;
}

/**
 * 引数の条件でクエリストリングを作成します。
 */
- (NSString *)makeQueryString:(AttendanceDomain *)condition {
    ENTER_METHOD
    
    NSMutableArray *fragments = [NSMutableArray array];
    
    if (condition.attCatNotYet) {
        [fragments addObject:@"attCat[]=0"];
    }
    if (condition.attCatAtt) {
        [fragments addObject:@"attCat[]=1"];
    }
    if (condition.attCatAbsence) {
        [fragments addObject:@"attCat[]=2"];
    }
    if (condition.attCatTardy) {
        [fragments addObject:@"attCat[]=3"];
    }
    if (condition.attCatEarlyLeaving) {
        [fragments addObject:@"attCat[]=4"];
    }
    if (condition.handoutCatNotYet) {
        [fragments addObject:@"handoutSitCat[]=0"];
    }
    if (condition.handoutCatDone) {
        [fragments addObject:@"handoutSitCat[]=1"];
    }
    if (condition.rcptCatNotYet) {
        [fragments addObject:@"rcptSitCat[]=0"];
    }
    if (condition.rcptCatDone) {
        [fragments addObject:@"rcptSitCat[]=1"];
    }
    NSString *projectName = condition.projectName;
    if (projectName && projectName.length > 0) {
        projectName = [Util urlEncode:projectName];
        [fragments addObject:[@"pjName=" stringByAppendingString:projectName]];
    }
    NSString *empName = condition.empName;
    if (empName && empName.length > 0) {
        empName = [Util urlEncode:empName];
        [fragments addObject:[@"empName=" stringByAppendingString:empName]];
    }
    NSString *empNoStart = condition.empNoStart;
    if (empNoStart && empNoStart.length > 0) {
        [fragments addObject:[@"empNoFrom=" stringByAppendingString:empNoStart]];
    }
    NSString *empNoEnd = condition.empNoEnd;
    if (empNoEnd && empNoEnd.length > 0) {
        [fragments addObject:[@"empNoTo=" stringByAppendingString:empNoEnd]];
    }
    
    NSString *query = @"";
    if (fragments.count > 0) {
        query = [@"?" stringByAppendingString:[fragments componentsJoinedByString:@"&"]];
    }
    
    LEAVE_METHOD
    
    return query;
}

/**
 * 引数の出欠情報を保存します。
 *
 * @params attendance 出欠情報
 */
- (void)update:(Attendance *)attendance error:(NSError **)error {
    ENTER_METHOD
    
    // リクエストボディの作成
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = TIMESTAMP_FORMAT;
    NSString *timeStamp = [formatter stringFromDate:attendance.timeStamp];
    NSString *query = [NSString stringWithFormat:@"id=%@&attCat=%@&dispCat=%@&empName=%@&empNo=%@&grpName=%@&handoutName=%@&handoutSitCat=%@&pjName=%@&postName=%@&rcptName=%@&rcptSitCat=%@&remCol=%@&seqNo=%@&timeStamp=%@",
                       attendance.id,
                       attendance.attCat,
                       attendance.dispCat,
                       attendance.empName,
                       attendance.empNo,
                       attendance.grpName,
                       attendance.handoutName,
                       attendance.handoutSitCat,
                       attendance.pjName,
                       attendance.postName,
                       attendance.rcptName,
                       attendance.rcptSitCat,
                       attendance.remCol,
                       attendance.seqNo,
                       timeStamp];
    NSData *httpBody = [query dataUsingEncoding:NSUTF8StringEncoding];
    
    // リクエストの作成
    NSString *url = [Util toAbsoluteUrl:@"/attendance"];
    if (!url) {
        *error = [[NSError alloc] initWithDomain:ERROR_DOMAIN_ATTENDANCE
                                            code:ERROR_CODE_UNKNOWN
                                        userInfo:@{@"Solvent" : @"Please setup Attendance Server."}];
        return ;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = httpBody;
    request.timeoutInterval = 5;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // リクエスト実行
    NSError *requestError = nil;
    NSData *jsonRawData = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil
                                                       error:&requestError];
    if (requestError) {
        [_delegate outputErrorLog:requestError forKey:@"updateProject#request"];
        *error = requestError;
        return;
    }
    
    // 取得した出欠情報（JSON）をパース
    NSError *jsonError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonRawData options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError) {
        [_delegate outputErrorLog:jsonError forKey:@"updateProject#json"];
        *error = jsonError;
        return;
    }
    
    // ステータスコードの確認
    NSString *statusCode = [json objectForKey:WS_KEY_STATUS_CODE];
    if ([WS_STATUS_OK isEqualToString:statusCode]) {
        // 正常
        return;
        
    } else if ([WS_STATUS_ERROR isEqualToString:statusCode]) {
        NSArray *errors = [json objectForKey:WS_KEY_ERRORS];
        NSDictionary *wsError = [errors objectAtIndex:0];
        NSString *errorCode = [wsError objectForKey:WS_KEY_ERROR_CODE];
        if ([STR_ERROR_CODE_OPTIMISTIC_LOCK isEqualToString:errorCode]) {
            // 楽観的排他エラー
            *error = [[NSError alloc] initWithDomain:ERROR_DOMAIN_ATTENDANCE code:ERROR_CODE_OPTIMISTIC_LOCK userInfo:nil];
            return;
        }
    }
    
    // その他予期しないステータス
    NSString *jsonString = [[NSString alloc]initWithData:jsonRawData encoding:NSUTF8StringEncoding];
    NSDictionary *userInfo = @{@"jsonString" : jsonString};
    NSError *statusError = [[NSError alloc] initWithDomain:ERROR_DOMAIN_ATTENDANCE code:ERROR_CODE_UNKNOWN userInfo:userInfo];
    [_delegate outputErrorLog:statusError forKey:@"updateProject#status"];
    *error = statusError;
    
    LEAVE_METHOD
}

/**
 * プロジェクトの一覧を取得します。
 *
 * @return プロジェクトの一覧
 */
- (NSArray *)findAllProject:(NSError **)error {
    ENTER_METHOD
    
    // リクエストの作成
    NSString *url = [Util toAbsoluteUrl:@"/attendance/project"];
    if (!url) {
        *error = [[NSError alloc] initWithDomain:ERROR_DOMAIN_ATTENDANCE
                                            code:ERROR_CODE_UNKNOWN
                                        userInfo:@{@"Reason" : @"出欠記録サーバーが設定されていません。"}];
        return @[];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = 5;
    
    // リクエスト実行
    NSError *requestError = nil;
    NSData *jsonRawData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
    if (requestError) {
        [_delegate outputErrorLog:requestError forKey:@"findAllProject#request"];
        *error = requestError;
        return @[];
    }
    
    // 取得した出欠情報（JSON）をパースしてAttendanceインスタンスを生成
    NSError *jsonError = nil;
    NSArray *jsonProjects = [NSJSONSerialization JSONObjectWithData:jsonRawData options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError) {
        [_delegate outputErrorLog:jsonError forKey:@"findAllProject#json"];
        *error = jsonError;
        return @[];
    }
    
    LEAVE_METHOD
    
    return jsonProjects;
}


@end
