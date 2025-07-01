import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideMenu(),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Column(
                children: [
                  // Logo and Header
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/respondnerlogo.png',
                        height: 80,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF8B1F1F),
                    padding: const EdgeInsets.all(6),
                    child: const Text(
                      'Meet the Team',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'We are a group of 3rd year Computer Science students from the Polytechnic University of the Philippines with one shared purpose: to help improve disaster response through technology that understands how Filipinos communicate online.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'During disasters, people turn to social media to ask for help, share their location, and report urgent needs. These messages are often written in Taglish, blending Tagalog and English, along with slang, emojis, and abbreviations. Traditional systems struggle to understand this type of language, which creates delays in getting the right help to the right people.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'We built a system that uses Artificial Intelligence and Named Entity Recognition (NER) to process Taglish disaster-related posts. It identifies names, places, organizations, and emergency-related terms in real time, transforming unstructured content into clear, usable data for emergency teams.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'This project is designed to support responders, local government units, NGOs, and analysts by highlighting the most important information when it\'s needed most. Our platform helps reduce information overload and brings structure to the chaos of social media during crises.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'We combined our skills and ideas to build a system that listens to real people in real time. What started as a university project became something we hope will make a difference.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}