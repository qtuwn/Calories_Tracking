import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/explore_template_migration_repository.dart';
import '../data/user_plan_consistency_repair_repository.dart';
import '../data/active_plan_repair_repository.dart';
import '../data/admin_audit_log_repository.dart';

/// Provider cho repository migration Explore Template.
final exploreTemplateMigrationRepoProvider =
    Provider<ExploreTemplateMigrationRepository>((ref) {
  final auditRepo = ref.watch(adminAuditLogRepoProvider);
  return FirestoreExploreTemplateMigrationRepository(auditRepo: auditRepo);
});

/// Provider cho repository sua loi tinh nhat quan plan nguoi dung.
final userPlanConsistencyRepairRepoProvider =
    Provider<UserPlanConsistencyRepairRepository>((ref) {
  final auditRepo = ref.watch(adminAuditLogRepoProvider);
  return FirestoreUserPlanConsistencyRepairRepository(auditRepo: auditRepo);
});

/// Provider cho repository sua loi active plan.
final activePlanRepairRepoProvider = Provider<ActivePlanRepairRepository>((ref) {
  final auditRepo = ref.watch(adminAuditLogRepoProvider);
  return FirestoreActivePlanRepairRepository(auditRepo: auditRepo);
});

/// Provider cho repository ghi admin audit log.
final adminAuditLogRepoProvider = Provider<AdminAuditLogRepository>((ref) {
  return FirestoreAdminAuditLogRepository();
});
