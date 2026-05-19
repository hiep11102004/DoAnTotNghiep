import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/aicoaching_bloc.dart';

class AICoachingPage extends StatelessWidget {
  const AICoachingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coaching'),
      ),
      body: BlocBuilder<AICoachingBloc, AICoachingState>(
        builder: (context, state) {
          if (state is AICoachingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AICoachingLoaded) {
            return ListView.builder(
              itemCount: state.coachings.length,
              itemBuilder: (context, index) {
                final coaching = state.coachings[index];
                return ListTile(
                  title: Text(coaching.topic),
                  subtitle: Text(coaching.description),
                );
              },
            );
          } else if (state is AICoachingError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No coachings found'));
        },
      ),
    );
  }
}
