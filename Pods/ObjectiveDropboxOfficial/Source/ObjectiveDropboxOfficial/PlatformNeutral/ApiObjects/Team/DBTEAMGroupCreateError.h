///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMGroupCreateError;

#pragma mark - API Object

///
/// The `GroupCreateError` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMGroupCreateError : NSObject <DBSerializable>

#pragma mark - Instance fields

/// The `DBTEAMGroupCreateErrorTag` enum type represents the possible tag states
/// with which the `DBTEAMGroupCreateError` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMGroupCreateErrorTag) {
  /// There is already an existing group with the requested name.
  DBTEAMGroupCreateErrorGroupNameAlreadyUsed,

  /// Group name is empty or has invalid characters.
  DBTEAMGroupCreateErrorGroupNameInvalid,

  /// The new external ID is already being used by another group.
  DBTEAMGroupCreateErrorExternalIdAlreadyInUse,

  /// (no description).
  DBTEAMGroupCreateErrorOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMGroupCreateErrorTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "group_name_already_used".
///
/// Description of the "group_name_already_used" tag state: There is already an
/// existing group with the requested name.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithGroupNameAlreadyUsed;

///
/// Initializes union class with tag state of "group_name_invalid".
///
/// Description of the "group_name_invalid" tag state: Group name is empty or
/// has invalid characters.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithGroupNameInvalid;

///
/// Initializes union class with tag state of "external_id_already_in_use".
///
/// Description of the "external_id_already_in_use" tag state: The new external
/// ID is already being used by another group.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithExternalIdAlreadyInUse;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithOther;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value
/// "group_name_already_used".
///
/// @return Whether the union's current tag state has value
/// "group_name_already_used".
///
- (BOOL)isGroupNameAlreadyUsed;

///
/// Retrieves whether the union's current tag state has value
/// "group_name_invalid".
///
/// @return Whether the union's current tag state has value
/// "group_name_invalid".
///
- (BOOL)isGroupNameInvalid;

///
/// Retrieves whether the union's current tag state has value
/// "external_id_already_in_use".
///
/// @return Whether the union's current tag state has value
/// "external_id_already_in_use".
///
- (BOOL)isExternalIdAlreadyInUse;

///
/// Retrieves whether the union's current tag state has value "other".
///
/// @return Whether the union's current tag state has value "other".
///
- (BOOL)isOther;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString * _Nonnull)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBTEAMGroupCreateError` union.
///
@interface DBTEAMGroupCreateErrorSerializer : NSObject

///
/// Serializes `DBTEAMGroupCreateError` instances.
///
/// @param instance An instance of the `DBTEAMGroupCreateError` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMGroupCreateError` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBTEAMGroupCreateError * _Nonnull)instance;

///
/// Deserializes `DBTEAMGroupCreateError` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMGroupCreateError` API object.
///
/// @return An instantiation of the `DBTEAMGroupCreateError` object.
///
+ (DBTEAMGroupCreateError * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
