import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/models/popular_tv_model.dart';
import '../../../cubit/api_cubit/api_service_cubit.dart';
import '../../../cubit/api_cubit/api_service_cubit_state.dart';
import '../../../cubit/fav_cubit/favourite_cubit.dart';
import '../../../widgets/card_widget.dart';
import '../../tv_screens/tv_detail_screen.dart';

class PopularTvPage extends StatefulWidget {
  const PopularTvPage({
    Key? key,
  }) : super(key: key);

  @override
  State<PopularTvPage> createState() => _PopularTvPageState();
}

class _PopularTvPageState extends State<PopularTvPage> {
  @override
  Widget build(BuildContext context) {
    final favCubit = context.watch<FavouriteMoviesShowsCubit>();
    return BlocBuilder<TvShowsCubit, ApiServiceCubit>(
      builder: (context, snapshot) {
        if (snapshot is PopularMoviesState) {
          final popTvs = snapshot.popularTvList;
          return SliverGrid.builder(
            itemCount: snapshot.popularTvList.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 130,
              crossAxisSpacing: 30,
              mainAxisSpacing: 11,
              mainAxisExtent: 240,
            ),
            itemBuilder: (BuildContext ctx, index) {
              return MovieTvCardWidget(
                popTv: popTvs[index],
                favCubit: favCubit,
                posterImage:
                    'https://image.tmdb.org/t/p/w500${popTvs[index].popTvPoster}',
                fromTrendingMovie: false,
                onTap: () {
                  context
                      .read<PopularTvDetailCubit>()
                      .fetchPopularTvDetail(popTvs[index].popTvId!.toDouble());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TvDetailPage(
                        showId: popTvs[index].popTvId!.toDouble(),
                      ),
                    ),
                  );
                },
                onFavouriteTap: () {
                  if (favCubit.isShowFavorited(popTvs[index]) == true) {
                    favCubit.removeFavShow(popTvs[index]);
                    return;
                  }
                  favCubit.addFavShow(popTvs[index]);
                },
              );
            },
          );
        } else if (snapshot is LoadingMovieState || snapshot is InitCubit) {
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        } else if (snapshot is ErrorMovieState) {
          return const SliverToBoxAdapter(
              child: Center(
            child: CircularProgressIndicator(),
          ));
        }
        return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.popTvs,
    required this.favCubit,
    required this.index,
  });

  final List<PopularTv> popTvs;
  final FavouriteMoviesShowsCubit favCubit;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              context
                  .read<PopularTvDetailCubit>()
                  .fetchPopularTvDetail(popTvs[index].popTvId!.toDouble());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TvDetailPage(
                    showId: popTvs[index].popTvId!.toDouble(),
                  ),
                ),
              );
            },
            child: Stack(
              // alignment: Alignment.topRight,
              children: [
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: NetworkImage(
                        'https://image.tmdb.org/t/p/w500${popTvs[index].popTvPoster}',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  left: 67,
                  right: 0,
                  bottom: 140,
                  child: IconButton(
                    onPressed: () {
                      if (favCubit.isShowFavorited(popTvs[index]) == true) {
                        favCubit.removeFavShow(popTvs[index]);
                        return;
                      }
                      favCubit.addFavShow(popTvs[index]);
                    },
                    icon: (favCubit.isShowFavorited(popTvs[index]))
                        ? const Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 20,
                                offset: Offset(0, 2.0),
                              )
                            ],
                          )
                        : const Icon(
                            Icons.favorite_outline_rounded,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 20,
                                offset: Offset(0, 2.0),
                              )
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,
            child: Text(
              popTvs[index].popTvTitle ?? '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
