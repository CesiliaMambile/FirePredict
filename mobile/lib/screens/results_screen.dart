import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  static const _figures = [
    {
      'asset': 'assets/model/figure1.png',
      'title': 'Fire Risk by Region',
      'description':
          'Average fire risk prediction across 7 Kilimanjaro locations. Machame, Marangu, Mweka and Shira Plateau show High risk (0.70), while Rongai and Karanga show Moderate risk (0.50). Kilema Area shows Low risk.',
    },
    {
      'asset': 'assets/model/figure2.png',
      'title': 'LSTM vs ConvLSTM Comparison',
      'description':
          'Fire risk prediction over 12 months comparing LSTM and ConvLSTM models. The ConvLSTM consistently predicts higher and more accurate risk levels, peaking at 0.90 during the dry season (Sept–Nov).',
    },
    {
      'asset': 'assets/model/figure3.png',
      'title': 'ConvLSTM Simulation 2021–2024',
      'description':
          'ConvLSTM simulation of predicted fire alerts from December 2021 to December 2024. Spikes in June 2022 and April–June 2024 correspond to known fire events at Kilimanjaro.',
    },
    {
      'asset': 'assets/model/figure4.png',
      'title': 'Weekly Risk Prediction 2023–2024',
      'description':
          'ConvLSTM weekly fire risk prediction from September 2023 to August 2024. Risk peaks at 0.79 in October during the dry season (highlighted), then drops sharply to below 0.25 in the wet season.',
    },
    {
      'asset': 'assets/model/figure5.png',
      'title': 'Spatial Fire Risk Maps 2021–2024',
      'description':
          'Predicted fire risk heatmaps across the Kilimanjaro region for 2021, 2022, 2023 and 2024. Darker red indicates higher fire risk. The model captures spatial patterns consistently across years.',
    },
    {
      'asset': 'assets/model/figure6.png',
      'title': 'Predicted Risk vs Historical Fires',
      'description':
          'Overlay of ConvLSTM predicted fire risk (heatmap) with historical fire occurrences (blue crosses) across Kilimanjaro. The model successfully identifies high-risk zones that align with recorded fire locations.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model Results')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _figures.length,
        itemBuilder: (context, i) {
          final fig = _figures[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: GestureDetector(
                    onTap: () => _showFullScreen(context, fig['asset']!,
                        fig['title']!),
                    child: Image.asset(
                      fig['asset']!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Figure ${i + 1}: ${fig['title']!}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fig['description']!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.5),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Tap image to enlarge',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFullScreen(BuildContext context, String asset, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.asset(asset),
            ),
          ),
        ),
      ),
    );
  }
}
