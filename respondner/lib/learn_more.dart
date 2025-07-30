import 'package:flutter/material.dart';

class LearnMorePage extends StatelessWidget {
  const LearnMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        toolbarHeight: 100, // Taller app bar
        title: SizedBox(
          height: 100, // Bigger logo
          child: Image.asset('assets/respondnerlogo.png'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ), // Prevent content from stretching too wide
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ), // Balanced padding
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCE1212), Color(0xFF9B1C1C)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "How does RespondNER Work?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "AI-powered support that transforms Taglish posts into rescue-ready data.",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "In disaster situations, people often take to social media to ask for help, report their location, or share what they urgently need. These posts are usually written in Taglish—a mix of Tagalog and English—and are often full of informal language, slang, emojis, and abbreviations. While these messages are rich with critical information, traditional systems struggle to process them.",
                  style: TextStyle(fontSize: 20, color: Color(0xFF374151)),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Our platform bridges that gap.",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                const Text.rich(
                  TextSpan(
                    text: "It uses ",
                    children: [
                      TextSpan(
                        text: "Named Entity Recognition (NER) ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "and "),
                      TextSpan(
                        text: "Natural Language Processing (NLP) ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "to analyze unstructured Taglish social media posts and extract meaningful data. The system identifies key people, locations, organizations, and emergency-related terms from real-time posts—helping response teams understand who needs help, where they are, and what kind of assistance they need.",
                      ),
                    ],
                    style: TextStyle(fontSize: 20, color: Color(0xFF374151)),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Unlike generic tools, this system is built with the Filipino context in mind. It understands Taglish, local expressions, and the way Filipinos naturally communicate online during crises. This makes it highly accurate in identifying relevant information, even from emotionally written or informal posts.",
                  style: TextStyle(fontSize: 20, color: Color(0xFF374151)),
                ),

                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  color: const Color(0xFFE5E7EB),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bulletStyle = const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1F2937),
                      );
                      return constraints.maxWidth > 600
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "With this technology, we aim to assist:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "• Disaster response teams looking for accurate field data",
                                        style: bulletStyle,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "• Government agencies and LGUs managing resources and relief",
                                        style: bulletStyle,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "• NGOs and community responders who need real-time updates",
                                        style: bulletStyle,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "• Researchers and analysts tracking social media impact",
                                        style: bulletStyle,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/opscenter1.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "With this technology, we aim to assist:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "• Disaster response teams looking for accurate field data",
                                  style: bulletStyle,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "• Government agencies and LGUs managing resources and relief",
                                  style: bulletStyle,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "• NGOs and community responders who need real-time updates",
                                  style: bulletStyle,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "• Researchers and analysts tracking social media impact",
                                  style: bulletStyle,
                                ),
                                const SizedBox(height: 20),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'asset/opscenter1.png',
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "The system filters out the noise and highlights what matters—turning overwhelming timelines into structured, actionable insights. It reduces response time and helps make better decisions when every second counts.",
                  style: TextStyle(fontSize: 20, color: Color(0xFF374151)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}