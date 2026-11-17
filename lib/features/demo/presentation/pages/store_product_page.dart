import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';

class StoreProductPage extends ConsumerStatefulWidget {
  final DemoStoreProduct product;

  const StoreProductPage({super.key, required this.product});

  @override
  ConsumerState<StoreProductPage> createState() => _StoreProductPageState();
}

class _StoreProductPageState extends ConsumerState<StoreProductPage> {
  late String _variant;
  final _nameCtrl = TextEditingController(text: 'Sofía Ramírez');
  final _cityCtrl = TextEditingController(text: 'Santo Domingo');
  final _addressCtrl = TextEditingController(text: 'Centro Olímpico, pista 1');
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _variant = widget.product.variants.isEmpty
        ? 'Único'
        : widget.product.variants.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    setState(() => _busy = true);
    final result = await ref
        .read(demoShowcaseRepositoryProvider)
        .checkout(
          productId: widget.product.id,
          variant: _variant,
          recipientName: _nameCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (order) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => StoreReceiptPage(order: order),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(product.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: product.imageUrl == null
                  ? const ColoredBox(
                      color: Color(0xFF1E293B),
                      child: Icon(
                        Icons.shopping_bag,
                        color: Colors.white24,
                        size: 64,
                      ),
                    )
                  : Semantics(
                      image: true,
                      label: 'Imagen de ${product.name}',
                      child: ExcludeSemantics(
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${product.price} ${product.currency}',
            style: const TextStyle(
              color: Color(0xFF5EEAD4),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description ?? '',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Talla o variante',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          Wrap(
            spacing: 8,
            children: product.variants
                .map(
                  (item) => ChoiceChip(
                    label: Text(item),
                    selected: _variant == item,
                    onSelected: (_) => setState(() => _variant = item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Entrega',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: _cityCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Ciudad'),
          ),
          TextField(
            controller: _addressCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Dirección'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _busy ? null : _checkout,
            child: Text(_busy ? 'Confirmando…' : 'Pagar y confirmar pedido'),
          ),
        ],
      ),
    );
  }
}

class StoreReceiptPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const StoreReceiptPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('Pedido confirmado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF5EEAD4), size: 56),
            const SizedBox(height: 16),
            Text(
              'Recibo ${order['id'] ?? ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${order['product_name'] ?? ''} · ${order['variant'] ?? ''}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '${order['amount'] ?? ''} ${order['currency'] ?? ''}',
              style: const TextStyle(color: Color(0xFF5EEAD4), fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              '${order['recipient_name'] ?? ''}\n${order['address'] ?? ''}, ${order['city'] ?? ''}',
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver a la tienda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
