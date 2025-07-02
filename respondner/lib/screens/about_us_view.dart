import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAccountsTitleBar(),
        _buildAboutUsParagraph(),
      ],
    );
  }

  Widget _buildAccountsTitleBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      width: double.infinity,
      color: const Color(0xFFa61c1c), // Using your app's red
      child: const Center(
        child: Text(
          'Meet the Team',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAboutUsParagraph() {
    return const Padding(
      padding: EdgeInsets.all(16.0), // Add some padding around the text
      child: Text(
        '''We are a group of 3rd year Computer Science students from the Polytechnic University of the Philippines with 
        one shared purpose: to help improve disaster response through technology that understands how Filipinos communicate 
        online. 
        During disasters, people turn to social media to ask for help, share their location, and report urgent needs. 
        These messages are often written in Taglish, blending Tagalog and English, along with slang, emojis, and abbreviations. 
        Traditional systems struggle to understand this type of language, which creates delays in getting the right help to the 
        right people.
        We built a system that uses Artificial Intelligence and Named Entity Recognition (NER) to process Taglish disaster-related 
        posts. It identifies names, places, organizations, and emergency-related terms in real time, transforming unstructured 
        content into clear, usable data for emergency teams.
        This project is designed to support responders, local government units, NGOs, and analysts by highlighting the most important 
        information when it’s needed most. Our platform helps reduce information overload and brings structure to the chaos of social 
        media during crises. We combined our skills and ideas to build a system that listens to real people in real time. What started 
        as a university project became something we hope will make a difference.''',
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
      ),
    );
  }
}