import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecase/get_wallets_usecase.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletsUseCase getWalletsUseCase;

  WalletBloc({
    required this.getWalletsUseCase,
  }) : super(const WalletInitial()) {
    on<GetWalletsEvent>(_onGetWallets);
  }

  Future<void> _onGetWallets(
    GetWalletsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final wallets = await getWalletsUseCase();
      emit(WalletLoaded(wallets));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
