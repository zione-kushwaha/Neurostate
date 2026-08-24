import 'package:flutter/material.dart';
import '../state/predictive_state_container.dart';
import 'detail_screen.dart';
import 'widgets/telemetry_hud.dart';

class ExploreScreen extends StatelessWidget {
  final PredictiveStateContainer stateContainer;

  const ExploreScreen({super.key, required this.stateContainer});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'AI & ML', 'icon': Icons.psychology, 'color': const Color(0xFF00E5FF), 'desc': 'Deep Learning, Transformers & Edge AI'},
      {'name': 'Systems', 'icon': Icons.memory, 'color': const Color(0xFF00C896), 'desc': 'Operating Systems, Runtimes & Kernels'},
      {'name': 'Mobile Computing', 'icon': Icons.phone_android, 'color': const Color(0xFF6C63FF), 'desc': 'Flutter, React Native & Native OS'},
      {'name': 'Cloud', 'icon': Icons.cloud_queue, 'color': const Color(0xFF00B0FF), 'desc': 'Distributed Systems & Microservices'},
      {'name': 'Cybersecurity', 'icon': Icons.security, 'color': const Color(0xFFFFB300), 'desc': 'Cryptography & Network Defense'},
      {'name': 'Algorithms', 'icon': Icons.account_tree, 'color': const Color(0xFFE040FB), 'desc': 'Optimization, Graphs & Complexity'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151D2A),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Explore Knowledge Matrix", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text("NeuroState Markov Transition Graph", style: TextStyle(fontSize: 11, color: Color(0xFF00E5FF))),
          ],
        ),
      ),
      body: Column(
        children: [
          const TelemetryHUD(architectureName: "App 4: NeuroState"),
          Expanded(
            child: AnimatedBuilder(
              animation: stateContainer,
              builder: (context, _) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      "RESEARCH DOMAINS",
                      style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final name = cat['name'] as String;
                        final icon = cat['icon'] as IconData;
                        final color = cat['color'] as Color;
                        final desc = cat['desc'] as String;

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            stateContainer.setCategory(name);
                            final match = stateContainer.articles.firstWhere(
                              (a) => a.category == name,
                              orElse: () => stateContainer.articles.first,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  articleId: match.id,
                                  stateContainer: stateContainer,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF151D2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF24334A)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "FEATURED RESEARCH AUTHORS",
                      style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    ...['Dr. Aris Thorne', 'Elena Rostova', 'Kenji Sato', 'Prof. Maya Lin'].map((author) {
                      return Card(
                        color: const Color(0xFF151D2A),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFF24334A)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF00E5FF).withAlpha(40),
                            child: Text(author[0], style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                          ),
                          title: Text(author, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text("Lead Investigator • 42 Publications", style: TextStyle(color: Colors.white38, fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                          onTap: () {
                            final match = stateContainer.articles.firstWhere(
                              (a) => a.author == author,
                              orElse: () => stateContainer.articles.first,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  articleId: match.id,
                                  stateContainer: stateContainer,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
