import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/products_repository_provider.dart';
// import 'package:teslo_shop/features/products/presentation/providers/products_repository_provider.dart';

//State Notifier Provider

//Provider
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final productsRepository = ref.watch(productsRepositoryProvider);
  
  return ProductsNotifier(
    productsRepository: productsRepository
    ); 
});

//Notifier
class ProductsNotifier extends StateNotifier<ProductsState> {

final ProductsRepository productsRepository;

  ProductsNotifier({
    required this.productsRepository
    }) : super(ProductsState()){
      loadNextPage();
    }

    Future<bool> createOrUpdateProduct(Map<String,dynamic> productLike) async{
      try {
        final product = await productsRepository.createUpdateProduct(productLike);
        final isProductInList = state.products.any((element) => element.id == product.id);

        //Sino existe
        if(!isProductInList){
          state.copyWith(
            products: [...state.products, product]
          );
        return true;
        }

        //Actualizar si existe
        state = state.copyWith(
          products: state.products.map(
            (elememt) => (elememt.id == product.id) ? product : elememt
          ).toList()
        );
        return true;
        
      } catch (e) {
        return false;
      }
    }

  Future loadNextPage() async{
    if(state.isLoading || state.isLastPage) return;

    state = state.copyWith( isLoading: true);

    final products = await productsRepository.
    getProductsByPage(limit: state.limit, offset: state.offset);

    if(products.isEmpty){
      state = state.copyWith(
        isLoading: false,
        isLastPage: true
        );
        return;
    }

    state = state.copyWith(
      isLastPage: false,
      isLoading: false,
      offset: state.offset + 10,
      products: [...state.products, ...products]
    );
  }
  
  
}

//STATE
class ProductsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Product> products;

  ProductsState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.products = const []});

  ProductsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Product>? products,
  }) =>
      ProductsState(
      isLastPage: isLastPage ?? this.isLastPage,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      );
}