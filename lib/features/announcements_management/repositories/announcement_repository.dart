import 'package:dartz/dartz.dart';
import '../models/announcement_model.dart';
import '../models/announcement_acknowledgment_model.dart';

abstract class AnnouncementRepository {
  // Get all announcements with filters and pagination
  Future<Either<String, AnnouncementResponse>> getAnnouncements({
    int page = 1,
    int limit = 20,
    int? institutionId,
    AnnouncementScope? scope,
    AnnouncementCategory? category,
    AnnouncementStatus? status,
    AnnouncementPriority? priority,
    String? search,
    int? authorId,
    bool publishedOnly = false,
  });

  // Get announcement by ID
  Future<Either<String, AnnouncementModel>> getAnnouncementById(int id);

  // Get announcement by UUID
  Future<Either<String, AnnouncementModel>> getAnnouncementByUuid(String uuid);

  // Create new announcement
  Future<Either<String, AnnouncementModel>> createAnnouncement({
    required int? institutionId,
    required AnnouncementScope scope,
    List<int>? scopeIds,
    List<String>? targetAudience,
    List<String>? targetLevels,
    required AnnouncementPriority priority,
    required AnnouncementCategory category,
    required AnnouncementType announcementType,
    required String title,
    required String content,
    String? excerpt,
    String? coverImageUrl,
    List<Attachment>? attachments,
    String? attachmentsUrl,
    String? externalLink,
    bool isPinned = false,
    bool isFeatured = false,
    bool showOnHomepage = false,
    bool requiresAcknowledgment = false,
    DateTime? publishAt,
    DateTime? expireAt,
    DateTime? expiresAt,
    AnnouncementStatus status = AnnouncementStatus.draft,
    bool allowComments = true,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });

  // Update existing announcement
  Future<Either<String, AnnouncementModel>> updateAnnouncement({
    required int id,
    int? institutionId,
    AnnouncementScope? scope,
    List<int>? scopeIds,
    List<String>? targetAudience,
    List<String>? targetLevels,
    AnnouncementPriority? priority,
    AnnouncementCategory? category,
    AnnouncementType? announcementType,
    String? title,
    String? content,
    String? excerpt,
    String? coverImageUrl,
    List<Attachment>? attachments,
    String? attachmentsUrl,
    String? externalLink,
    bool? isPinned,
    bool? isFeatured,
    bool? showOnHomepage,
    bool? requiresAcknowledgment,
    DateTime? publishAt,
    DateTime? expireAt,
    DateTime? expiresAt,
    AnnouncementStatus? status,
    bool? allowComments,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });

  // Delete announcement (soft delete)
  Future<Either<String, bool>> deleteAnnouncement(int id);

  // Get announcements for current user
  Future<Either<String, AnnouncementResponse>> getAnnouncementsForUser({
    int page = 1,
    int limit = 20,
  });

  // Get statistics
  Future<Either<String, AnnouncementStatistics>> getStatistics({
    int? institutionId,
  });

  // Acknowledge announcement
  Future<Either<String, bool>> acknowledgeAnnouncement(int announcementId);

  // Get pending acknowledgments for current user
  Future<Either<String, List<PendingAcknowledgment>>> getPendingAcknowledgments();

  // Get acknowledgments for announcement
  Future<Either<String, List<AnnouncementAcknowledgmentModel>>> getAnnouncementAcknowledgments({
    required int announcementId,
    int page = 1,
    int limit = 50,
  });

  // Get acknowledgment statistics for announcement
  Future<Either<String, List<AcknowledgmentStatistics>>> getAcknowledgmentStatistics({
    required int announcementId,
  });

  // Get acknowledgments by user
  Future<Either<String, List<AnnouncementAcknowledgmentModel>>> getUserAcknowledgments({
    required int userId,
    int page = 1,
    int limit = 20,
  });

  // Search announcements
  Future<Either<String, AnnouncementResponse>> searchAnnouncements({
    required String query,
    int page = 1,
    int limit = 20,
    AnnouncementCategory? category,
    AnnouncementScope? scope,
    AnnouncementPriority? priority,
  });

  // Get pinned announcements
  Future<Either<String, List<AnnouncementModel>>> getPinnedAnnouncements({
    int? institutionId,
    AnnouncementScope? scope,
  });

  // Get featured announcements
  Future<Either<String, List<AnnouncementModel>>> getFeaturedAnnouncements({
    int? institutionId,
    int limit = 5,
  });

  // Get announcements by category
  Future<Either<String, AnnouncementResponse>> getAnnouncementsByCategory({
    required AnnouncementCategory category,
    int page = 1,
    int limit = 20,
    int? institutionId,
  });

  // Get announcements by priority
  Future<Either<String, AnnouncementResponse>> getAnnouncementsByPriority({
    required AnnouncementPriority priority,
    int page = 1,
    int limit = 20,
    int? institutionId,
  });

  // Get recent announcements
  Future<Either<String, List<AnnouncementModel>>> getRecentAnnouncements({
    int limit = 10,
    int? institutionId,
    AnnouncementScope? scope,
  });

  // Get upcoming scheduled announcements
  Future<Either<String, List<AnnouncementModel>>> getUpcomingScheduledAnnouncements({
    int? institutionId,
  });

  // Get expired announcements
  Future<Either<String, List<AnnouncementModel>>> getExpiredAnnouncements({
    int page = 1,
    int limit = 20,
    int? institutionId,
  });

  // Get announcements requiring acknowledgment
  Future<Either<String, List<AnnouncementModel>>> getAnnouncementsRequiringAcknowledgment({
    int page = 1,
    int limit = 20,
    int? institutionId,
  });

  // Get announcements by author
  Future<Either<String, AnnouncementResponse>> getAnnouncementsByAuthor({
    required int authorId,
    int page = 1,
    int limit = 20,
  });

  // Get announcements by date range
  Future<Either<String, AnnouncementResponse>> getAnnouncementsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 20,
    int? institutionId,
  });

  // Get announcements with attachments
  Future<Either<String, List<AnnouncementModel>>> getAnnouncementsWithAttachments({
    int page = 1,
    int limit = 20,
    int? institutionId,
  });

  // Get announcements by tags
  Future<Either<String, AnnouncementResponse>> getAnnouncementsByTags({
    required List<String> tags,
    int page = 1,
    int limit = 20,
    int? institutionId,
  });

  // Get announcement analytics
  Future<Either<String, Map<String, dynamic>>> getAnnouncementAnalytics({
    required int announcementId,
  });

  // Increment view count
  Future<Either<String, bool>> incrementViewCount(int announcementId);

  // Share announcement
  Future<Either<String, bool>> shareAnnouncement({
    required int announcementId,
    required String platform,
  });

  // Get sharing statistics
  Future<Either<String, Map<String, dynamic>>> getSharingStatistics({
    required int announcementId,
  });

  // Export announcements
  Future<Either<String, String>> exportAnnouncements({
    AnnouncementCategory? category,
    AnnouncementScope? scope,
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  });

  // Import announcements
  Future<Either<String, List<AnnouncementModel>>> importAnnouncements({
    required String filePath,
    required String format,
  });

  // Bulk operations
  Future<Either<String, bool>> bulkUpdateStatus({
    required List<int> announcementIds,
    required AnnouncementStatus status,
  });

  Future<Either<String, bool>> bulkDelete({
    required List<int> announcementIds,
  });

  Future<Either<String, bool>> bulkPin({
    required List<int> announcementIds,
    required bool isPinned,
  });

  Future<Either<String, bool>> bulkFeature({
    required List<int> announcementIds,
    required bool isFeatured,
  });

  // Template operations
  Future<Either<String, AnnouncementModel>> createAnnouncementFromTemplate({
    required int templateId,
    Map<String, dynamic>? customData,
  });

  Future<Either<String, List<AnnouncementModel>>> getAnnouncementTemplates({
    int? institutionId,
  });

  Future<Either<String, bool>> saveAnnouncementAsTemplate({
    required int announcementId,
    required String templateName,
    String? templateDescription,
  });

  // Notification operations
  Future<Either<String, bool>> sendAnnouncementNotifications({
    required int announcementId,
    List<int>? specificUserIds,
    bool forceSend = false,
  });

  Future<Either<String, Map<String, dynamic>>> getNotificationStatus({
    required int announcementId,
  });

  Future<Either<String, bool>> scheduleNotification({
    required int announcementId,
    required DateTime scheduledTime,
  });

  // Comment operations
  Future<Either<String, List<Map<String, dynamic>>>> getAnnouncementComments({
    required int announcementId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<String, bool>> addAnnouncementComment({
    required int announcementId,
    required String content,
    int? parentId,
  });

  Future<Either<String, bool>> updateAnnouncementComment({
    required int commentId,
    required String content,
  });

  Future<Either<String, bool>> deleteAnnouncementComment({
    required int commentId,
  });

  // Reporting operations
  Future<Either<String, Map<String, dynamic>>> generateAnnouncementReport({
    int? institutionId,
    DateTime? startDate,
    DateTime? endDate,
    AnnouncementCategory? category,
    AnnouncementScope? scope,
    String reportType = 'summary',
  });

  Future<Either<String, String>> exportAnnouncementReport({
    required Map<String, dynamic> reportData,
    String format = 'pdf',
  });

  // Archive operations
  Future<Either<String, bool>> archiveAnnouncement(int announcementId);

  Future<Either<String, bool>> restoreAnnouncement(int announcementId);

  Future<Either<String, List<AnnouncementModel>>> getArchivedAnnouncements({
    int page = 1,
    int limit = 20,
    int? institutionId,
  });

  // Validation operations
  Future<Either<String, Map<String, dynamic>>> validateAnnouncementData({
    required Map<String, dynamic> announcementData,
  });

  Future<Either<String, List<String>>> getAnnouncementValidationRules();

  // Cache operations
  Future<Either<String, bool>> clearAnnouncementCache({
    int? announcementId,
    int? institutionId,
  });

  Future<Either<String, bool>> preloadAnnouncementCache({
    List<int>? announcementIds,
    int? institutionId,
  });

  // Subscription operations
  Future<Either<String, bool>> subscribeToAnnouncements({
    required List<AnnouncementCategory> categories,
    List<AnnouncementScope>? scopes,
    int? institutionId,
  });

  Future<Either<String, bool>> unsubscribeFromAnnouncements({
    List<AnnouncementCategory>? categories,
    List<AnnouncementScope>? scopes,
    int? institutionId,
  });

  Future<Either<String, Map<String, dynamic>>> getAnnouncementSubscriptions();

  // Permission operations
  Future<Either<String, Map<String, dynamic>>> getUserPermissions();

  Future<Either<String, bool>> canCreateAnnouncement();

  Future<Either<String, bool>> canEditAnnouncement(int announcementId);

  Future<Either<String, bool>> canDeleteAnnouncement(int announcementId);

  Future<Either<String, bool>> canManageAnnouncements({
    int? institutionId,
  });
}
