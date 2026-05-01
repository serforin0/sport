import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/job_offer.dart';

import '../../../../core/widgets/skeleton_base.dart';


class JobCardWidget extends StatelessWidget {
  final JobOffer job;
  final VoidCallback? onTap;

  const JobCardWidget({
    super.key,
    required this.job,
    this.onTap,
  });

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1C4B8F))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Logo
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: job.companyLogoUrl != null
                    ? Hero(
                        tag: 'job_logo_${job.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: job.companyLogoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SkeletonBase(borderRadius: 4),
                            errorWidget: (context, url, error) => const Icon(Icons.business, color: Color(0xFF001A43)),
                          ),
                        ),
                      )
                    : const Icon(Icons.business, color: Color(0xFF001A43)),
              ),


            ),
            const SizedBox(width: 12),
            // Job Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    job.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF19B5FF),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(job.createdAt),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget skeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A5B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBase(width: 50, height: 50, borderRadius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBase(width: 150, height: 16),
                SizedBox(height: 6),
                SkeletonBase(width: 100, height: 14),
                SizedBox(height: 6),
                SkeletonBase(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

