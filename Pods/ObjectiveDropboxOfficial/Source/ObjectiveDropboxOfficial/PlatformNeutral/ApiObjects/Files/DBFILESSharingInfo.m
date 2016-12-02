///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import "DBFILESSharingInfo.h"
#import "DBStoneSerializers.h"
#import "DBStoneValidators.h"

#pragma mark - API Object

@implementation DBFILESSharingInfo

#pragma mark - Constructors

- (instancetype)initWithReadOnly:(NSNumber *)readOnly {

  self = [super init];
  if (self) {
    _readOnly = readOnly;
  }
  return self;
}

#pragma mark - Serialization methods

+ (NSDictionary *)serialize:(id)instance {
  return [DBFILESSharingInfoSerializer serialize:instance];
}

+ (id)deserialize:(NSDictionary *)dict {
  return [DBFILESSharingInfoSerializer deserialize:dict];
}

#pragma mark - Description method

- (NSString *)description {
  return [[DBFILESSharingInfoSerializer serialize:self] description];
}

@end

#pragma mark - Serializer Object

@implementation DBFILESSharingInfoSerializer

+ (NSDictionary *)serialize:(DBFILESSharingInfo *)valueObj {
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];

  jsonDict[@"read_only"] = valueObj.readOnly;

  return jsonDict;
}

+ (DBFILESSharingInfo *)deserialize:(NSDictionary *)valueDict {
  NSNumber *readOnly = valueDict[@"read_only"];

  return [[DBFILESSharingInfo alloc] initWithReadOnly:readOnly];
}

@end
