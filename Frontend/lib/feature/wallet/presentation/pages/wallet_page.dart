import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wallet_bloc.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WalletLoaded) {
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
          } else if (state is WalletError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No wallets found'));
        },
      ),
    );
  }
}
