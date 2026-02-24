// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    NotificationDto(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NotificationDtoToJson(NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'payload': instance.payload,
      'read': instance.read,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

NotificationPageDto _$NotificationPageDtoFromJson(Map<String, dynamic> json) =>
    NotificationPageDto(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );

Map<String, dynamic> _$NotificationPageDtoToJson(
        NotificationPageDto instance) =>
    <String, dynamic>{
      'notifications': instance.notifications.map((e) => e.toJson()).toList(),
      'totalCount': instance.totalCount,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrevious': instance.hasPrevious,
    };

NotificationStatsDto _$NotificationStatsDtoFromJson(
        Map<String, dynamic> json) =>
    NotificationStatsDto(
      totalNotifications: (json['totalNotifications'] as num).toInt(),
      unreadNotifications: (json['unreadNotifications'] as num).toInt(),
      readNotifications: (json['readNotifications'] as num).toInt(),
      notificationsToday: (json['notificationsToday'] as num).toInt(),
      notificationsThisWeek: (json['notificationsThisWeek'] as num).toInt(),
      notificationsThisMonth: (json['notificationsThisMonth'] as num).toInt(),
      typeDistribution: Map<String, int>.from(json['typeDistribution'] as Map),
      lastNotificationDate: json['lastNotificationDate'] == null
          ? null
          : DateTime.parse(json['lastNotificationDate'] as String),
      averageNotificationsPerDay:
          (json['averageNotificationsPerDay'] as num).toDouble(),
    );

Map<String, dynamic> _$NotificationStatsDtoToJson(
        NotificationStatsDto instance) =>
    <String, dynamic>{
      'totalNotifications': instance.totalNotifications,
      'unreadNotifications': instance.unreadNotifications,
      'readNotifications': instance.readNotifications,
      'notificationsToday': instance.notificationsToday,
      'notificationsThisWeek': instance.notificationsThisWeek,
      'notificationsThisMonth': instance.notificationsThisMonth,
      'typeDistribution': instance.typeDistribution,
      'lastNotificationDate': instance.lastNotificationDate?.toIso8601String(),
      'averageNotificationsPerDay': instance.averageNotificationsPerDay,
    };
