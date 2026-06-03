import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_state.dart'; // 👉 FIX 2: Đã thêm dòng này

class WalletPage extends StatelessWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      // 👉 FIX 1: Viết hoa chữ W thành WalletBloc
      body: BlocBuilder<WalletBloc, WalletState>( 
        builder: (context, state) {
          
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (state is WalletLoaded) {
            return ListView.builder(
              itemCount: state.wallets.length,
              itemBuilder: (context, index) {
                final wallet = state.wallets[index];
                return ListTile(
                  title: Text(wallet.name),
                  subtitle: Text('Balance: ${wallet.balance} ${wallet.currency}'),
                );
              },
            );
          }

          if (state is WalletError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          // 👉 FIX 3: Thêm return mặc định khi chưa có gì xảy ra (WalletInitial)
          return const Center(child: Text('Đang tải dữ liệu ví...')); 
        },
      ),
    );
  }
}