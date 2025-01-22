import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import '../errors/product_erros.dart';
import 'package:teslo_shop/features/products/infrastructure/mappers/product_mapper.dart';

class ProductsDatasourceImpl extends ProductsDatasource {
  //Se ocupa Dio
  late final Dio dio;
  final String accessToken;

  ProductsDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}
            )
            );

            //Una sola imagen
            Future<String> _uploadFile (String path) async{
              try {
                final fileName = path.split('/').last; //Corta todo con el '/' y se queda con el nombre del último '/'
                
                final FormData data = FormData.fromMap({ //Transformar a Json
                  'file' : MultipartFile.fromFileSync(path, filename: fileName)
                });
                final response = await dio.post('/files/product', data: data);
                
                return response.data['image'];

              } catch (e) {
                throw Exception();
              }
            }

            //Varias imágenes
            Future<List<String>> _uploadPhoto(List<String> photo ) async{
              final photosToUpload = photo.where(
                (element) => element.contains('/')  //Si tiene '/' viene de fileSystem
                ).toList();

                final photoToIgnore = photo.where(
                  (element) => !element.contains('/')
                ).toList();

                //TODO Crear una serie de Futures de carga de imágenes
                final List<Future<String>> uploadJob = photosToUpload.map( _uploadFile).toList();

                final newImages = await Future.wait(uploadJob);

                return [...photoToIgnore, ...newImages];
            }

  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike) async{
    try {
      final String? productId = productLike['id'];
      final String method = (productId == null) ? 'POST' : 'PATCH';
      final String url = (productId == null) ? '/products' : '/products/$productId';
      
      productLike.remove('id');
      productLike['images'] = await _uploadPhoto( productLike['images'] );
      // throw Exception();

      final response = await dio.request(
        url,
        data: productLike,
        options: Options(
          method: method
        )
      );

      final product = ProductMapper.jsonToEntity(response.data);

      return product;


    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Product> getProductsById(String id) async {
    try {
      final response = await dio.get('/products/$id');
      final product = ProductMapper.jsonToEntity(response.data);

      return product;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();

      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Product>> getProductsByPage(
      {int limit = 10, int offset = 0}) async {
    final response =
        await dio.get<List>('/products?limit=$limit&offset=$offset');
    final List<Product> products = [];
    for (final product in response.data ?? []) {
      products.add(ProductMapper.jsonToEntity(product));
    }

    return products;
  }

  @override
  Future<List<Product>> searchProductByTerm(String term) {
    // TODO: implement searchProductByTerm
    throw UnimplementedError();
  }
}
