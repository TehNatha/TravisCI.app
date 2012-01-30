//
//  BWBuild.h
//  TravisCI
//
//  Created by Bradley Grzesiak on 12/21/11.
//  Refer to MIT-LICENSE file at root of project for copyright info
//

#import "BWPresenter.h"
#import "RestKit/RKObjectLoader.h"

@interface BWBuild : BWPresenter

- (void)fetchJobs;

@property (readonly) NSString *formattedNumber;

@property (nonatomic, strong) NSNumber *remote_id;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *author_email;
@property (nonatomic, strong) NSString *author_name;
@property (nonatomic, strong) NSString *commit;
@property (nonatomic, strong) NSString *committer_name;
@property (nonatomic, strong) NSString *compare_url;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSNumber *repository_id;
@property (nonatomic, strong) NSNumber *result;

@end
