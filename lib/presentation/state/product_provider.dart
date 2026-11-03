import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dummy_data.dart';
import '../../data/models/product.dart';
import '../../data/repositories/firestore_repository.dart';

// Selected category notifier
class SelectedCategoryNotifier extends Notifier<ProductCategory> {
  @override
  ProductCategory build() => ProductCategory.all;

  void select(ProductCategory category) => state = category;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, ProductCategory>(
  SelectedCategoryNotifier.new,
);

// Search query notifier
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// Master products list notifier
class ProductsNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    _loadFromFirestore();
    return DummyData.initialProducts;
  }

  Future<void> _loadFromFirestore() async {
    try {
      final products = await FirestoreRepository().getProducts();
      if (products.isNotEmpty) {
        state = products;
      }
    } catch (_) {}
  }

  void addProduct(Product product) {
    state = [product, ...state];
  }

  void updateStock(String productId, int quantityDeducted) {
    state = state.map((p) {
      if (p.id == productId && p.category != ProductCategory.services) {
        final newStock = (p.stockQuantity - quantityDeducted).clamp(0, 99999);
        return Product(
          id: p.id,
          code: p.code,
          nameKh: p.nameKh,
          nameEn: p.nameEn,
          category: p.category,
          unitPriceUSD: p.unitPriceUSD,
          costPriceUSD: p.costPriceUSD,
          stockQuantity: newStock,
          minStockAlert: p.minStockAlert,
          unit: p.unit,
          image: p.image,
          tire: p.tire,
          battery: p.battery,
          engineOil: p.engineOil,
          sparePart: p.sparePart,
        );
      }
      return p;
    }).toList();
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

// Filtered products list based on category and search query
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return products.where((product) {
    // 1. Category check
    if (category != ProductCategory.all && product.category != category) {
      return false;
    }

    // 2. Search query check
    if (query.isEmpty) return true;

    final inNameKh = product.nameKh.toLowerCase().contains(query);
    final inNameEn = product.nameEn.toLowerCase().contains(query);
    final inCode = product.code.toLowerCase().contains(query);
    final inTire = product.tire != null &&
        (product.tire!.size.toLowerCase().contains(query) ||
            product.tire!.brand.toLowerCase().contains(query));
    final inBattery = product.battery != null &&
        (product.battery!.terminalType.toLowerCase().contains(query) ||
            product.battery!.brand.toLowerCase().contains(query) ||
            '${product.battery!.capacityAh}ah'.contains(query));
    final inOil = product.engineOil != null &&
        (product.engineOil!.viscosity.toLowerCase().contains(query) ||
            product.engineOil!.brand.toLowerCase().contains(query));
    final inPart = product.sparePart != null &&
        (product.sparePart!.oemPartNumber.toLowerCase().contains(query) ||
            product.sparePart!.compatibility.toLowerCase().contains(query));

    return inNameKh || inNameEn || inCode || inTire || inBattery || inOil || inPart;
  }).toList();
});
