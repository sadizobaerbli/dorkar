import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dorkar/data/models/category_model.dart';
import 'package:dorkar/data/models/products_model.dart';
import 'package:dorkar/data/services/connectivity_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import '../../data/services/home_repository.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeRepository repository;
  ConnectivityRepository connectivityRepository;
  HomeBloc({required this.connectivityRepository, required this.repository})
      : super(HomeLoadingState()) {
    //===============Connectivity checking portion================
    //------------------------------------------------------------
    connectivityRepository.connectivityStream.stream.listen((event) {
      if (event == ConnectivityResult.none) {
        add(HomeConnectionErrorEvent());
      } else {
        add(HomeCategoryProductsEvent());
      }
    });

    //==================Event portion==================
    //-------------------------------------------------
    on<HomeCategoryProductsEvent>((event, emit) async {
      // TODO: implement event handler
      try {
        final response = await repository.getAllCategories();
        final responseProducts = await repository.getAllProducts();

        CategoryModel _categoryModel = CategoryModel.fromJson(response.data);
        ProductsModel _productsModel =
            ProductsModel.fromJson(responseProducts.data);
        int itemsPerPage = 10;
        List<List<CategoryData>> itemPerPageList = [];
        for (var i = 0; i < _categoryModel.data!.length; i += itemsPerPage) {
          itemPerPageList.add(_categoryModel.data!.sublist(
              i,
              i + itemsPerPage > _categoryModel.data!.length
                  ? _categoryModel.data!.length
                  : i + itemsPerPage));
        }
        emit(HomeLoadedState(itemPerPageList, _productsModel));
      } on DioError catch (e) {
        emit(HomeFailureState(errorString: e.message));
      }
    });

    on<HomeConnectionErrorEvent>((event, emit) {
      // TODO: implement event handler
      emit(HomeConnectionErrorState());
    });
  }
}
