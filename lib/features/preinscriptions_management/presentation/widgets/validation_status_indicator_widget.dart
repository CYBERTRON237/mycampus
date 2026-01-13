import 'package:flutter/material.dart';
import '../../models/preinscription_model.dart';

class ValidationStatusIndicatorWidget extends StatelessWidget {
  final PreinscriptionModel preinscription;
  final double? size;

  const ValidationStatusIndicatorWidget({
    Key? key,
    required this.preinscription,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicatorSize = size ?? 24.0;
    final statusColor = _getStatusColor(preinscription.status);
    final statusIcon = _getStatusIcon(preinscription.status);
    
    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          statusIcon,
          size: indicatorSize * 0.6,
          color: statusColor,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'under_review': return Colors.blue;
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      case 'deferred': return Colors.purple;
      case 'waitlisted': return Colors.amber;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.pending;
      case 'under_review': return Icons.visibility;
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'cancelled': return Icons.block;
      case 'deferred': return Icons.schedule;
      case 'waitlisted': return Icons.hourglass_empty;
      default: return Icons.help;
    }
  }
}

class ValidationStatusBadgeWidget extends StatelessWidget {
  final PreinscriptionModel preinscription;
  final bool showLabel;
  final double? fontSize;

  const ValidationStatusBadgeWidget({
    Key? key,
    required this.preinscription,
    this.showLabel = true,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(preinscription.status);
    final statusText = _formatStatusName(preinscription.status);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 12.0 : 8.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(preinscription.status),
            size: 16,
            color: statusColor,
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: fontSize ?? 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'under_review': return Colors.blue;
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      case 'deferred': return Colors.purple;
      case 'waitlisted': return Colors.amber;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.pending;
      case 'under_review': return Icons.visibility;
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'cancelled': return Icons.block;
      case 'deferred': return Icons.schedule;
      case 'waitlisted': return Icons.hourglass_empty;
      default: return Icons.help;
    }
  }

  String _formatStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'En attente';
      case 'under_review': return 'En révision';
      case 'accepted': return 'Accepté';
      case 'rejected': return 'Rejeté';
      case 'cancelled': return 'Annulé';
      case 'deferred': return 'Reporté';
      case 'waitlisted': return 'Liste d\'attente';
      default: return status;
    }
  }
}

class ValidationProgressBarWidget extends StatelessWidget {
  final PreinscriptionModel preinscription;
  final double? height;

  const ValidationProgressBarWidget({
    Key? key,
    required this.preinscription,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress(preinscription);
    final progressColor = _getProgressColor(preinscription.status);
    
    return Container(
      height: height ?? 8,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  double _calculateProgress(PreinscriptionModel preinscription) {
    switch (preinscription.status.toLowerCase()) {
      case 'pending': return 0.25;
      case 'under_review': return 0.5;
      case 'accepted': return 1.0;
      case 'rejected': return 0.75;
      case 'cancelled': return 0.0;
      case 'deferred': return 0.6;
      case 'waitlisted': return 0.4;
      default: return 0.0;
    }
  }

  Color _getProgressColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'under_review': return Colors.blue;
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      case 'deferred': return Colors.purple;
      case 'waitlisted': return Colors.amber;
      default: return Colors.grey;
    }
  }
}

class ValidationTimelineWidget extends StatelessWidget {
  final PreinscriptionModel preinscription;

  const ValidationTimelineWidget({
    Key? key,
    required this.preinscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = _getValidationSteps(preinscription);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline de Validation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...steps.map((step) => _buildTimelineStep(context, step)),
        ],
      ),
    );
  }

  List<ValidationStep> _getValidationSteps(PreinscriptionModel preinscription) {
    final steps = <ValidationStep>[];
    
    // Step 1: Submission
    steps.add(ValidationStep(
      title: 'Soumission',
      description: 'Préinscription soumise',
      date: preinscription.submissionDate,
      status: StepStatus.completed,
      icon: Icons.send,
    ));
    
    // Step 2: Initial Review
    if (preinscription.status == 'under_review' || 
        preinscription.status == 'accepted' || 
        preinscription.status == 'rejected') {
      steps.add(ValidationStep(
        title: 'Révision Initiale',
        description: 'Examen des informations',
        date: preinscription.reviewDate ?? preinscription.lastUpdated,
        status: StepStatus.completed,
        icon: Icons.visibility,
      ));
    } else {
      steps.add(ValidationStep(
        title: 'Révision Initiale',
        description: 'En attente de révision',
        date: null,
        status: StepStatus.pending,
        icon: Icons.visibility,
      ));
    }
    
    // Step 3: Interview (if required)
    if (preinscription.interviewRequired) {
      if (preinscription.interviewDate != null) {
        steps.add(ValidationStep(
          title: 'Entretien',
          description: 'Entretien planifié',
          date: preinscription.interviewDate,
          status: preinscription.interviewResult == 'passed' 
              ? StepStatus.completed 
              : StepStatus.inProgress,
          icon: Icons.calendar_today,
        ));
      } else {
        steps.add(ValidationStep(
          title: 'Entretien',
          description: 'Entretien requis',
          date: null,
          status: StepStatus.pending,
          icon: Icons.calendar_today,
        ));
      }
    }
    
    // Step 4: Final Decision
    switch (preinscription.status.toLowerCase()) {
      case 'accepted':
        steps.add(ValidationStep(
          title: 'Décision Finale',
          description: 'Préinscription acceptée',
          date: preinscription.lastUpdated,
          status: StepStatus.completed,
          icon: Icons.check_circle,
        ));
        break;
      case 'rejected':
        steps.add(ValidationStep(
          title: 'Décision Finale',
          description: 'Préinscription rejetée',
          date: preinscription.lastUpdated,
          status: StepStatus.completed,
          icon: Icons.cancel,
        ));
        break;
      default:
        steps.add(ValidationStep(
          title: 'Décision Finale',
          description: 'En attente de décision',
          date: null,
          status: StepStatus.pending,
          icon: Icons.gavel,
        ));
    }
    
    return steps;
  }

  Widget _buildTimelineStep(BuildContext context, ValidationStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with status indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getStepStatusColor(step.status).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getStepStatusColor(step.status),
                width: 2,
              ),
            ),
            child: Icon(
              step.icon,
              size: 16,
              color: _getStepStatusColor(step.status),
            ),
          ),
          const SizedBox(width: 12),
          
          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getStepStatusColor(step.status),
                  ),
                ),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (step.date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(step.date!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepStatusColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed: return Colors.green;
      case StepStatus.inProgress: return Colors.blue;
      case StepStatus.pending: return Colors.grey;
      case StepStatus.failed: return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class ValidationStep {
  final String title;
  final String description;
  final DateTime? date;
  final StepStatus status;
  final IconData icon;

  ValidationStep({
    required this.title,
    required this.description,
    this.date,
    required this.status,
    required this.icon,
  });
}

enum StepStatus {
  pending,
  inProgress,
  completed,
  failed,
}
