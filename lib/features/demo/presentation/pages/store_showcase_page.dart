import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/demo/presentation/pages/store_product_page.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';
import 'package:sport/features/demo/presentation/widgets/demo_error_view.dart';

class StoreShowcasePage extends ConsumerWidget {
  const StoreShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showcase = ref.watch(demoShowcaseProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('Tienda'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: DemoBadge()),
          ),
        ],
      ),
      body: showcase.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Cargando tienda'),
        ),
        error: (_, _) => DemoErrorView(
          message: 'No se pudo cargar la tienda.',
          onRetry: () => ref.invalidate(demoShowcaseProvider),
        ),
        data: (data) {
          if (data.storeProducts.isEmpty) {
            return const Center(
              child: Text(
                'No hay productos en el entorno demo',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: data.storeProducts.length,
            itemBuilder: (context, index) {
              final product = data.storeProducts[index];
              return Card(
                color: const Color(0xFF1E293B),
                clipBehavior: Clip.antiAlias,
                child: Semantics(
                  button: true,
                  label:
                      'Abrir ${product.name}, '
                      '${product.price} ${product.currency}',
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => StoreProductPage(product: product),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: product.imageUrl == null
                                ? const Center(
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Color(0xFF60A5FA),
                                      size: 56,
                                    ),
                                  )
                                : Semantics(
                                    image: true,
                                    label: 'Imagen de ${product.name}',
                                    child: ExcludeSemantics(
                                      child: CachedNetworkImage(
                                        imageUrl: product.imageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                          ),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${product.price} ${product.currency}',
                            style: const TextStyle(
                              color: Color(0xFF5EEAD4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
