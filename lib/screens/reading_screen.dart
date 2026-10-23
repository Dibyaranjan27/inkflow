import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inkflow/constants.dart';
import 'package:inkflow/screens/bookmark_screen.dart';
import 'package:inkflow/screens/home_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening URLs
import 'dart:convert';

class ReadingScreen extends StatefulWidget {
  final Map<String, dynamic> bookData; // Receive dynamic book data

  ReadingScreen({required this.bookData}); // Constructor

  @override
  _ReadingScreenState createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  String bookName = '';
  String chapterName = '';
  String chapterDescription = '';
  List<String> bookContent = [];
  String webReaderLink = '';
  bool isLoading = true;
  String bookCover = '';
  int currentPage = 0;
  String pages = '100';
  bool isDarkMode = false; // Dark mode state
  bool isChapterCompleted =
      false; // Track chapter completion// User email from Shared Preferences

  final List<String> storyContent = [
    "Once upon a time in a small village, there lived a young girl named Ella. Ella loved to explore the enchanted forest that bordered her home. She would often spend hours wandering its winding paths, marveling at the tall trees, sparkling streams, and the symphony of chirping birds and rustling leaves. One day, while wandering deeper into the woods than ever before, she stumbled upon a hidden glade filled with flowers of every color. The vibrant hues danced in the sunlight, creating a breathtaking tapestry that captivated her senses. \n\nIn the center of the glade stood a magnificent tree with shimmering leaves that glistened like emeralds. Its branches stretched high into the sky, and its trunk was adorned with intricate carvings that seemed to tell ancient stories. As Ella approached the tree, she heard a soft voice calling her name. \"Ella, come closer!\" it beckoned. She was astonished to find a tiny fairy perched on one of the branches, her wings sparkling like diamonds.\n\nThe fairy introduced herself as Lila and explained that she was the guardian of the forest. Lila had watched over the glade for centuries, ensuring that the flowers remained safe and vibrant. However, she revealed that a dark sorcerer named Malakar had set his sights on the enchanted glade, seeking to steal the flowers' magic for himself. \"The flowers hold immense power,\" Lila explained, her voice trembling with urgency. \"If he succeeds, the forest will wither and die.\"\n",
    "Ella's heart raced at the thought of losing the beauty she cherished so dearly. Determined to help, she agreed to join Lila in protecting the magical flowers. Together, they devised a plan to outsmart the sorcerer. They spent the next few days gathering supplies from the forest, collecting herbs and ingredients to create protective charms. Ella learned to weave enchantments into the flowers, making them shimmer with an ethereal glow that would confuse any intruder.\n\nAs they trained, Lila shared tales of the forest's history, telling Ella about the magical creatures that inhabited it—gentle deer that could speak, wise owls that kept watch over the night, and playful sprites that danced among the stars. Ella felt a deep connection to the forest and its inhabitants, understanding that she was part of something much greater than herself.\n\nWhen the day of the confrontation arrived, Ella stood bravely beside Lila, ready to face the sorcerer. The sky darkened as ominous clouds gathered overhead, mirroring the tension in the air. Ella felt a rush of fear, but she pushed it aside, focusing on the bond she had formed with Lila and the strength they shared.\n\nAs Malakar approached, his shadow loomed over the glade, and the flowers trembled in fear. \"You think you can stop me, little girl?\" he sneered, his voice echoing through the trees. But Ella stood tall, her heart pounding with determination. With courage in her heart, she used her cleverness and quick thinking to trick the sorcerer into believing he was surrounded by magical creatures. She whispered incantations Lila had taught her, making the flowers glow brighter and shimmer in the dim light.\n",
    "Confused and scared, the sorcerer stumbled backward, glancing around in panic as illusions of fearsome creatures danced before his eyes. Believing he was outnumbered, he fled the glade, never to return. Ella and Lila cheered, their laughter echoing through the trees. The forest was safe once more.\n\nAs the sun broke through the clouds, casting golden rays over the glade, Ella was hailed as a hero. The flowers bloomed more vibrantly than ever, each petal a testament to her bravery. With Lila by her side, they celebrated their victory, dancing among the blossoms. The forest flourished under Lila's protection, and Ella felt a sense of belonging that she had never experienced before.\n\nFrom that day on, Ella knew that magic existed, not just in the forest, but within her own heart as well. She visited Lila often, learning more about the secrets of the enchanted world. Together, they forged an unbreakable bond, vowing to protect the forest and its wonders for generations to come. And whenever Ella ventured into the woods, she carried the knowledge that true strength comes from friendship, courage, and the magic that lies within us all.",
    "Once upon a time in a small village, there lived a young girl named Ella. With her auburn hair tied in a loose braid and sparkling green eyes, Ella was known for her adventurous spirit. She loved to explore the enchanted forest that bordered her home, a place filled with wonders that stirred her imagination. Every day after school, she would escape into the woods, finding solace among the towering trees and the gentle murmur of the nearby stream. One sunny afternoon, while wandering deeper into the woods than ever before, she stumbled upon a hidden glade filled with flowers of every color, each petal glistening like jewels under the sun.\n\nIn the center of the glade stood a magnificent tree with shimmering leaves that sparkled like diamonds. Its branches were heavy with blossoms, and its gnarled roots seemed to tell stories of ancient times. As Ella approached the tree, she heard a soft voice calling her name, sweet and melodious. \"Ella, come closer!\" it beckoned. Curiosity piqued, she stepped forward and was astonished to find a tiny fairy perched on one of the branches, her wings glimmering with iridescent colors that changed with the light.\n\nThe fairy introduced herself as Lila, the guardian of the forest. With a twinkle in her eye, she explained that she had watched over the glade for centuries, ensuring that the flowers remained safe and vibrant. But trouble loomed on the horizon. A dark sorcerer named Malakar had set his sights on the enchanted glade, seeking to steal the flowers' magic for himself. \"The flowers hold immense power,\" Lila explained, her voice tinged with urgency. \"If he succeeds, the forest will wither, and its magic will fade forever.\"\n\nElla's heart raced at the thought of losing the beauty she cherished so dearly. \"What can I do to help?\" she asked, determination flashing in her eyes. Lila smiled, grateful for Ella's bravery. Together, they devised a plan to outsmart the sorcerer. They spent days gathering supplies from the forest, collecting herbs and ingredients to create protective charms. Ella learned to weave enchantments into the flowers, making them shimmer with a light that could confuse any intruder.",
    "As they trained, Lila shared tales of the forest's history. Ella learned about the mystical creatures that called the woods home—the gentle deer that could speak wisdom, wise owls that watched over the night skies, and mischievous sprites that played tricks on unsuspecting travelers. Ella felt a deep connection to the forest, understanding that she was part of something much greater than herself.\n\nOne day, while exploring a different part of the forest, Ella discovered an ancient stone archway covered in vines. Intrigued, she stepped through it and found herself in a realm filled with magical creatures. There were unicorns grazing in a meadow, and a river of sparkling water flowed nearby. In this enchanted place, she met a wise old tortoise named Orin, who possessed knowledge of the forest's deepest secrets. He told Ella that to truly protect the glade, she needed to harness the magic within herself. \"You must believe in your power, young one,\" Orin advised. \"The strength of your heart can create wonders.\"\n\nElla returned to Lila, invigorated by her encounter. Together, they continued their preparations, practicing spells and strategies to defend the glade. When the day of the confrontation arrived, the sky darkened with ominous clouds, mirroring the tension in the air. Ella felt a rush of fear, but she pushed it aside, focusing on the bond she had formed with Lila and the strength they shared.\n\nAs Malakar approached, his shadow loomed over the glade, and the flowers trembled in fear. \"You think you can stop me, little girl?\" he sneered, his voice echoing through the trees. Ella stood tall, her heart pounding with determination. Remembering Orin’s words, she whispered a spell that filled her with light. With courage in her heart, she used her cleverness and quick thinking to trick the sorcerer into believing he was surrounded by magical creatures. She conjured illusions of fierce beasts and shimmering sprites that danced around him.",
    "Confused and terrified, Malakar stumbled backward, glancing around in panic. His dark magic faltered as he struggled to comprehend the scene before him. Sensing victory, Ella and Lila combined their magic, their energies intertwining to form a protective barrier around the glade. \"The magic of friendship is stronger than any darkness!\" Ella declared, and with a final surge of power, they banished the sorcerer from the glade, his terrified screams fading into the distance.\n\nAs the sun broke through the clouds, casting golden rays over the glade, Ella was hailed as a hero. The flowers bloomed more vibrantly than ever, each petal a testament to her bravery and heart. With Lila by her side, they celebrated their victory, dancing among the blossoms, laughter echoing through the trees. The forest flourished under Lila's protection, and Ella felt a sense of belonging that she had never experienced before.\n\nFrom that day on, Ella visited Lila often, learning more about the secrets of the enchanted world. They explored hidden paths, encountered friendly creatures, and shared stories by the glimmering streams. Ella discovered that true magic resided not just in spells and charms, but in the kindness and courage one carried in their heart. Together, they forged an unbreakable bond, vowing to protect the forest and its wonders for generations to come. Whenever Ella ventured into the woods, she carried the knowledge that true strength comes from friendship, courage, and the magic that lies within us all.\n\nAnd so, the enchanted forest thrived, its beauty preserved for those who believed in the magic of nature and the power of the heart.",
    "Once upon a time in a small village, there lived a young girl named Ella. Ella loved to explore the enchanted forest that bordered her home. She would often spend hours wandering its winding paths, marveling at the tall trees, sparkling streams, and the symphony of chirping birds and rustling leaves. One day, while wandering deeper into the woods than ever before, she stumbled upon a hidden glade filled with flowers of every color. The vibrant hues danced in the sunlight, creating a breathtaking tapestry that captivated her senses. \n\nIn the center of the glade stood a magnificent tree with shimmering leaves that glistened like emeralds. Its branches stretched high into the sky, and its trunk was adorned with intricate carvings that seemed to tell ancient stories. As Ella approached the tree, she heard a soft voice calling her name. \"Ella, come closer!\" it beckoned. She was astonished to find a tiny fairy perched on one of the branches, her wings sparkling like diamonds.\n\nThe fairy introduced herself as Lila and explained that she was the guardian of the forest. Lila had watched over the glade for centuries, ensuring that the flowers remained safe and vibrant. However, she revealed that a dark sorcerer named Malakar had set his sights on the enchanted glade, seeking to steal the flowers' magic for himself. \"The flowers hold immense power,\" Lila explained, her voice trembling with urgency. \"If he succeeds, the forest will wither and die.\"\n",
    "Ella's heart raced at the thought of losing the beauty she cherished so dearly. Determined to help, she agreed to join Lila in protecting the magical flowers. Together, they devised a plan to outsmart the sorcerer. They spent the next few days gathering supplies from the forest, collecting herbs and ingredients to create protective charms. Ella learned to weave enchantments into the flowers, making them shimmer with an ethereal glow that would confuse any intruder.\n\nAs they trained, Lila shared tales of the forest's history, telling Ella about the magical creatures that inhabited it—gentle deer that could speak, wise owls that kept watch over the night, and playful sprites that danced among the stars. Ella felt a deep connection to the forest and its inhabitants, understanding that she was part of something much greater than herself.\n\nWhen the day of the confrontation arrived, Ella stood bravely beside Lila, ready to face the sorcerer. The sky darkened as ominous clouds gathered overhead, mirroring the tension in the air. Ella felt a rush of fear, but she pushed it aside, focusing on the bond she had formed with Lila and the strength they shared.\n\nAs Malakar approached, his shadow loomed over the glade, and the flowers trembled in fear. \"You think you can stop me, little girl?\" he sneered, his voice echoing through the trees. But Ella stood tall, her heart pounding with determination. With courage in her heart, she used her cleverness and quick thinking to trick the sorcerer into believing he was surrounded by magical creatures. She whispered incantations Lila had taught her, making the flowers glow brighter and shimmer in the dim light.\n",
    "Confused and scared, the sorcerer stumbled backward, glancing around in panic as illusions of fearsome creatures danced before his eyes. Believing he was outnumbered, he fled the glade, never to return. Ella and Lila cheered, their laughter echoing through the trees. The forest was safe once more.\n\nAs the sun broke through the clouds, casting golden rays over the glade, Ella was hailed as a hero. The flowers bloomed more vibrantly than ever, each petal a testament to her bravery. With Lila by her side, they celebrated their victory, dancing among the blossoms. The forest flourished under Lila's protection, and Ella felt a sense of belonging that she had never experienced before.\n\nFrom that day on, Ella knew that magic existed, not just in the forest, but within her own heart as well. She visited Lila often, learning more about the secrets of the enchanted world. Together, they forged an unbreakable bond, vowing to protect the forest and its wonders for generations to come. And whenever Ella ventured into the woods, she carried the knowledge that true strength comes from friendship, courage, and the magic that lies within us all.",
    "Once upon a time in a small village, there lived a young girl named Ella. With her auburn hair tied in a loose braid and sparkling green eyes, Ella was known for her adventurous spirit. She loved to explore the enchanted forest that bordered her home, a place filled with wonders that stirred her imagination. Every day after school, she would escape into the woods, finding solace among the towering trees and the gentle murmur of the nearby stream. One sunny afternoon, while wandering deeper into the woods than ever before, she stumbled upon a hidden glade filled with flowers of every color, each petal glistening like jewels under the sun.\n\nIn the center of the glade stood a magnificent tree with shimmering leaves that sparkled like diamonds. Its branches were heavy with blossoms, and its gnarled roots seemed to tell stories of ancient times. As Ella approached the tree, she heard a soft voice calling her name, sweet and melodious. \"Ella, come closer!\" it beckoned. Curiosity piqued, she stepped forward and was astonished to find a tiny fairy perched on one of the branches, her wings glimmering with iridescent colors that changed with the light.\n\nThe fairy introduced herself as Lila, the guardian of the forest. With a twinkle in her eye, she explained that she had watched over the glade for centuries, ensuring that the flowers remained safe and vibrant. But trouble loomed on the horizon. A dark sorcerer named Malakar had set his sights on the enchanted glade, seeking to steal the flowers' magic for himself. \"The flowers hold immense power,\" Lila explained, her voice tinged with urgency. \"If he succeeds, the forest will wither, and its magic will fade forever.\"\n\nElla's heart raced at the thought of losing the beauty she cherished so dearly. \"What can I do to help?\" she asked, determination flashing in her eyes. Lila smiled, grateful for Ella's bravery. Together, they devised a plan to outsmart the sorcerer. They spent days gathering supplies from the forest, collecting herbs and ingredients to create protective charms. Ella learned to weave enchantments into the flowers, making them shimmer with a light that could confuse any intruder.",
    "As they trained, Lila shared tales of the forest's history. Ella learned about the mystical creatures that called the woods home—the gentle deer that could speak wisdom, wise owls that watched over the night skies, and mischievous sprites that played tricks on unsuspecting travelers. Ella felt a deep connection to the forest, understanding that she was part of something much greater than herself.\n\nOne day, while exploring a different part of the forest, Ella discovered an ancient stone archway covered in vines. Intrigued, she stepped through it and found herself in a realm filled with magical creatures. There were unicorns grazing in a meadow, and a river of sparkling water flowed nearby. In this enchanted place, she met a wise old tortoise named Orin, who possessed knowledge of the forest's deepest secrets. He told Ella that to truly protect the glade, she needed to harness the magic within herself. \"You must believe in your power, young one,\" Orin advised. \"The strength of your heart can create wonders.\"\n\nElla returned to Lila, invigorated by her encounter. Together, they continued their preparations, practicing spells and strategies to defend the glade. When the day of the confrontation arrived, the sky darkened with ominous clouds, mirroring the tension in the air. Ella felt a rush of fear, but she pushed it aside, focusing on the bond she had formed with Lila and the strength they shared.\n\nAs Malakar approached, his shadow loomed over the glade, and the flowers trembled in fear. \"You think you can stop me, little girl?\" he sneered, his voice echoing through the trees. Ella stood tall, her heart pounding with determination. Remembering Orin’s words, she whispered a spell that filled her with light. With courage in her heart, she used her cleverness and quick thinking to trick the sorcerer into believing he was surrounded by magical creatures. She conjured illusions of fierce beasts and shimmering sprites that danced around him.",
    "Confused and terrified, Malakar stumbled backward, glancing around in panic. His dark magic faltered as he struggled to comprehend the scene before him. Sensing victory, Ella and Lila combined their magic, their energies intertwining to form a protective barrier around the glade. \"The magic of friendship is stronger than any darkness!\" Ella declared, and with a final surge of power, they banished the sorcerer from the glade, his terrified screams fading into the distance.\n\nAs the sun broke through the clouds, casting golden rays over the glade, Ella was hailed as a hero. The flowers bloomed more vibrantly than ever, each petal a testament to her bravery and heart. With Lila by her side, they celebrated their victory, dancing among the blossoms, laughter echoing through the trees. The forest flourished under Lila's protection, and Ella felt a sense of belonging that she had never experienced before.\n\nFrom that day on, Ella visited Lila often, learning more about the secrets of the enchanted world. They explored hidden paths, encountered friendly creatures, and shared stories by the glimmering streams. Ella discovered that true magic resided not just in spells and charms, but in the kindness and courage one carried in their heart. Together, they forged an unbreakable bond, vowing to protect the forest and its wonders for generations to come. Whenever Ella ventured into the woods, she carried the knowledge that true strength comes from friendship, courage, and the magic that lies within us all.\n\nAnd so, the enchanted forest thrived, its beauty preserved for those who believed in the magic of nature and the power of the heart.",
    "Once upon a time in a small village, there lived a young girl named Ella. Ella loved to explore the enchanted forest that bordered her home. She would often spend hours wandering its winding paths, marveling at the tall trees, sparkling streams, and the symphony of chirping birds and rustling leaves. One day, while wandering deeper into the woods than ever before, she stumbled upon a hidden glade filled with flowers of every color. The vibrant hues danced in the sunlight, creating a breathtaking tapestry that captivated her senses. \n\nIn the center of the glade stood a magnificent tree with shimmering leaves that glistened like emeralds. Its branches stretched high into the sky, and its trunk was adorned with intricate carvings that seemed to tell ancient stories. As Ella approached the tree, she heard a soft voice calling her name. \"Ella, come closer!\" it beckoned. She was astonished to find a tiny fairy perched on one of the branches, her wings sparkling like diamonds.\n\nThe fairy introduced herself as Lila and explained that she was the guardian of the forest. Lila had watched over the glade for centuries, ensuring that the flowers remained safe and vibrant. However, she revealed that a dark sorcerer named Malakar had set his sights on the enchanted glade, seeking to steal the flowers' magic for himself. \"The flowers hold immense power,\" Lila explained, her voice trembling with urgency. \"If he succeeds, the forest will wither and die.\"\n",
    "Ella's heart raced at the thought of losing the beauty she cherished so dearly. Determined to help, she agreed to join Lila in protecting the magical flowers. Together, they devised a plan to outsmart the sorcerer. They spent the next few days gathering supplies from the forest, collecting herbs and ingredients to create protective charms. Ella learned to weave enchantments into the flowers, making them shimmer with an ethereal glow that would confuse any intruder.\n\nAs they trained, Lila shared tales of the forest's history, telling Ella about the magical creatures that inhabited it—gentle deer that could speak, wise owls that kept watch over the night, and playful sprites that danced among the stars. Ella felt a deep connection to the forest and its inhabitants, understanding that she was part of something much greater than herself.\n\nWhen the day of the confrontation arrived, Ella stood bravely beside Lila, ready to face the sorcerer. The sky darkened as ominous clouds gathered overhead, mirroring the tension in the air. Ella felt a rush of fear, but she pushed it aside, focusing on the bond she had formed with Lila and the strength they shared.\n\nAs Malakar approached, his shadow loomed over the glade, and the flowers trembled in fear. \"You think you can stop me, little girl?\" he sneered, his voice echoing through the trees. But Ella stood tall, her heart pounding with determination. With courage in her heart, she used her cleverness and quick thinking to trick the sorcerer into believing he was surrounded by magical creatures. She whispered incantations Lila had taught her, making the flowers glow brighter and shimmer in the dim light.\n",
    "Confused and scared, the sorcerer stumbled backward, glancing around in panic as illusions of fearsome creatures danced before his eyes. Believing he was outnumbered, he fled the glade, never to return. Ella and Lila cheered, their laughter echoing through the trees. The forest was safe once more.\n\nAs the sun broke through the clouds, casting golden rays over the glade, Ella was hailed as a hero. The flowers bloomed more vibrantly than ever, each petal a testament to her bravery. With Lila by her side, they celebrated their victory, dancing among the blossoms. The forest flourished under Lila's protection, and Ella felt a sense of belonging that she had never experienced before.\n\nFrom that day on, Ella knew that magic existed, not just in the forest, but within her own heart as well. She visited Lila often, learning more about the secrets of the enchanted world. Together, they forged an unbreakable bond, vowing to protect the forest and its wonders for generations to come. And whenever Ella ventured into the woods, she carried the knowledge that true strength comes from friendship, courage, and the magic that lies within us all.",
    "Once upon a time in a small village, there lived a young girl named Ella. With her auburn hair tied in a loose braid and sparkling green eyes, Ella was known for her adventurous spirit. She loved to explore the enchanted forest that bordered her home, a place filled with wonders that stirred her imagination. Every day after school, she would escape into the woods, finding solace among the towering trees and the gentle murmur of the nearby stream. One sunny afternoon, while wandering deeper into the woods than ever before, she stumbled upon a hidden glade filled with flowers of every color, each petal glistening like jewels under the sun.\n\nIn the center of the glade stood a magnificent tree with shimmering leaves that sparkled like diamonds. Its branches were heavy with blossoms, and its gnarled roots seemed to tell stories of ancient times. As Ella approached the tree, she heard a soft voice calling her name, sweet and melodious. \"Ella, come closer!\" it beckoned. Curiosity piqued, she stepped forward and was astonished to find a tiny fairy perched on one of the branches, her wings glimmering with iridescent colors that changed with the light.\n\nThe fairy introduced herself as Lila, the guardian of the forest. With a twinkle in her eye, she explained that she had watched over the glade for centuries, ensuring that the flowers remained safe and vibrant. But trouble loomed on the horizon. A dark sorcerer named Malakar had set his sights on the enchanted glade, seeking to steal the flowers' magic for himself. \"The flowers hold immense power,\" Lila explained, her voice tinged with urgency. \"If he succeeds, the forest will wither, and its magic will fade forever.\"\n\nElla's heart raced at the thought of losing the beauty she cherished so dearly. \"What can I do to help?\" she asked, determination flashing in her eyes. Lila smiled, grateful for Ella's bravery. Together, they devised a plan to outsmart the sorcerer. They spent days gathering supplies from the forest, collecting herbs and ingredients to create protective charms. Ella learned to weave enchantments into the flowers, making them shimmer with a light that could confuse any intruder.",
    "As they trained, Lila shared tales of the forest's history. Ella learned about the mystical creatures that called the woods home—the gentle deer that could speak wisdom, wise owls that watched over the night skies, and mischievous sprites that played tricks on unsuspecting travelers. Ella felt a deep connection to the forest, understanding that she was part of something much greater than herself.\n\nOne day, while exploring a different part of the forest, Ella discovered an ancient stone archway covered in vines. Intrigued, she stepped through it and found herself in a realm filled with magical creatures. There were unicorns grazing in a meadow, and a river of sparkling water flowed nearby. In this enchanted place, she met a wise old tortoise named Orin, who possessed knowledge of the forest's deepest secrets. He told Ella that to truly protect the glade, she needed to harness the magic within herself. \"You must believe in your power, young one,\" Orin advised. \"The strength of your heart can create wonders.\"\n\nElla returned to Lila, invigorated by her encounter. Together, they continued their preparations, practicing spells and strategies to defend the glade. When the day of the confrontation arrived, the sky darkened with ominous clouds, mirroring the tension in the air. Ella felt a rush of fear, but she pushed it aside, focusing on the bond she had formed with Lila and the strength they shared.\n\nAs Malakar approached, his shadow loomed over the glade, and the flowers trembled in fear. \"You think you can stop me, little girl?\" he sneered, his voice echoing through the trees. Ella stood tall, her heart pounding with determination. Remembering Orin’s words, she whispered a spell that filled her with light. With courage in her heart, she used her cleverness and quick thinking to trick the sorcerer into believing he was surrounded by magical creatures. She conjured illusions of fierce beasts and shimmering sprites that danced around him.",
    "Confused and terrified, Malakar stumbled backward, glancing around in panic. His dark magic faltered as he struggled to comprehend the scene before him. Sensing victory, Ella and Lila combined their magic, their energies intertwining to form a protective barrier around the glade. \"The magic of friendship is stronger than any darkness!\" Ella declared, and with a final surge of power, they banished the sorcerer from the glade, his terrified screams fading into the distance.\n\nAs the sun broke through the clouds, casting golden rays over the glade, Ella was hailed as a hero. The flowers bloomed more vibrantly than ever, each petal a testament to her bravery and heart. With Lila by her side, they celebrated their victory, dancing among the blossoms, laughter echoing through the trees. The forest flourished under Lila's protection, and Ella felt a sense of belonging that she had never experienced before.\n\nFrom that day on, Ella visited Lila often, learning more about the secrets of the enchanted world. They explored hidden paths, encountered friendly creatures, and shared stories by the glimmering streams. Ella discovered that true magic resided not just in spells and charms, but in the kindness and courage one carried in their heart. Together, they forged an unbreakable bond, vowing to protect the forest and its wonders for generations to come. Whenever Ella ventured into the woods, she carried the knowledge that true strength comes from friendship, courage, and the magic that lies within us all.\n\nAnd so, the enchanted forest thrived, its beauty preserved for those who believed in the magic of nature and the power of the heart.",
    "Once upon a time in a small village, there lived a young girl named Ella. Ella loved to explore the enchanted forest that bordered her home. She would often spend hours wandering its winding paths, marveling at the tall trees, sparkling streams, and the symphony of chirping birds and rustling leaves. One day, while wandering deeper into the woods than ever before, she stumbled upon a hidden glade filled with flowers of every color. The vibrant hues danced in the sunlight, creating a breathtaking tapestry that captivated her senses. \n\nIn the center of the glade stood a magnificent tree with shimmering leaves that glistened like emeralds. Its branches stretched high into the sky, and its trunk was adorned with intricate carvings that seemed to tell ancient stories. As Ella approached the tree, she heard a soft voice calling her name. \"Ella, come closer!\" it beckoned. She was astonished to find a tiny fairy perched on one of the branches, her wings sparkling like diamonds.\n\nThe fairy introduced herself as Lila and explained that she was the guardian of the forest. Lila had watched over the glade for centuries, ensuring that the flowers remained safe and vibrant. However, she revealed that a dark sorcerer named Malakar had set his sights on the enchanted glade, seeking to steal the flowers' magic for himself. \"The flowers hold immense power,\" Lila explained, her voice trembling with urgency. \"If he succeeds, the forest will wither and die.\"\n",
    "Ella's heart raced at the thought of losing the beauty she cherished so dearly. Determined to help, she agreed to join Lila in protecting the magical flowers. Together, they devised a plan to outsmart the sorcerer. They spent the next few days gathering supplies from the forest, collecting herbs and ingredients to create protective charms. Ella learned to weave enchantments into the flowers, making them shimmer with an ethereal glow that would confuse any intruder.\n\nAs they trained, Lila shared tales of the forest's history, telling Ella about the magical creatures that inhabited it—gentle deer that could speak, wise owls that kept watch over the night, and playful sprites that danced among the stars. Ella felt a deep connection to the forest and its inhabitants, understanding that she was part of something much greater than herself.\n\nWhen the day of the confrontation arrived, Ella stood bravely beside Lila, ready to face the sorcerer. The sky darkened as ominous clouds gathered overhead, mirroring the tension in the air. Ella felt a rush of fear, but she pushed it aside, focusing on the bond she had formed with Lila and the strength they shared.\n\nAs Malakar approached, his shadow loomed over the glade, and the flowers trembled in fear. \"You think you can stop me, little girl?\" he sneered, his voice echoing through the trees. But Ella stood tall, her heart pounding with determination. With courage in her heart, she used her cleverness and quick thinking to trick the sorcerer into believing he was surrounded by magical creatures. She whispered incantations Lila had taught her, making the flowers glow brighter and shimmer in the dim light.\n",
    "Confused and scared, the sorcerer stumbled backward, glancing around in panic as illusions of fearsome creatures danced before his eyes. Believing he was outnumbered, he fled the glade, never to return. Ella and Lila cheered, their laughter echoing through the trees. The forest was safe once more.\n\nAs the sun broke through the clouds, casting golden rays over the glade, Ella was hailed as a hero. The flowers bloomed more vibrantly than ever, each petal a testament to her bravery. With Lila by her side, they celebrated their victory, dancing among the blossoms. The forest flourished under Lila's protection, and Ella felt a sense of belonging that she had never experienced before.\n\nFrom that day on, Ella knew that magic existed, not just in the forest, but within her own heart as well. She visited Lila often, learning more about the secrets of the enchanted world. Together, they forged an unbreakable bond, vowing to protect the forest and its wonders for generations to come. And whenever Ella ventured into the woods, she carried the knowledge that true strength comes from friendship, courage, and the magic that lies within us all.",
    "Once upon a time in a small village, there lived a young girl named Ella. With her auburn hair tied in a loose braid and sparkling green eyes, Ella was known for her adventurous spirit. She loved to explore the enchanted forest that bordered her home, a place filled with wonders that stirred her imagination. Every day after school, she would escape into the woods, finding solace among the towering trees and the gentle murmur of the nearby stream. One sunny afternoon, while wandering deeper into the woods than ever before, she stumbled upon a hidden glade filled with flowers of every color, each petal glistening like jewels under the sun.\n\nIn the center of the glade stood a magnificent tree with shimmering leaves that sparkled like diamonds. Its branches were heavy with blossoms, and its gnarled roots seemed to tell stories of ancient times. As Ella approached the tree, she heard a soft voice calling her name, sweet and melodious. \"Ella, come closer!\" it beckoned. Curiosity piqued, she stepped forward and was astonished to find a tiny fairy perched on one of the branches, her wings glimmering with iridescent colors that changed with the light.\n\nThe fairy introduced herself as Lila, the guardian of the forest. With a twinkle in her eye, she explained that she had watched over the glade for centuries, ensuring that the flowers remained safe and vibrant. But trouble loomed on the horizon. A dark sorcerer named Malakar had set his sights on the enchanted glade, seeking to steal the flowers' magic for himself. \"The flowers hold immense power,\" Lila explained, her voice tinged with urgency. \"If he succeeds, the forest will wither, and its magic will fade forever.\"\n\nElla's heart raced at the thought of losing the beauty she cherished so dearly. \"What can I do to help?\" she asked, determination flashing in her eyes. Lila smiled, grateful for Ella's bravery. Together, they devised a plan to outsmart the sorcerer. They spent days gathering supplies from the forest, collecting herbs and ingredients to create protective charms. Ella learned to weave enchantments into the flowers, making them shimmer with a light that could confuse any intruder.",
    "As they trained, Lila shared tales of the forest's history. Ella learned about the mystical creatures that called the woods home—the gentle deer that could speak wisdom, wise owls that watched over the night skies, and mischievous sprites that played tricks on unsuspecting travelers. Ella felt a deep connection to the forest, understanding that she was part of something much greater than herself.\n\nOne day, while exploring a different part of the forest, Ella discovered an ancient stone archway covered in vines. Intrigued, she stepped through it and found herself in a realm filled with magical creatures. There were unicorns grazing in a meadow, and a river of sparkling water flowed nearby. In this enchanted place, she met a wise old tortoise named Orin, who possessed knowledge of the forest's deepest secrets. He told Ella that to truly protect the glade, she needed to harness the magic within herself. \"You must believe in your power, young one,\" Orin advised. \"The strength of your heart can create wonders.\"\n\nElla returned to Lila, invigorated by her encounter. Together, they continued their preparations, practicing spells and strategies to defend the glade. When the day of the confrontation arrived, the sky darkened with ominous clouds, mirroring the tension in the air. Ella felt a rush of fear, but she pushed it aside, focusing on the bond she had formed with Lila and the strength they shared.\n\nAs Malakar approached, his shadow loomed over the glade, and the flowers trembled in fear. \"You think you can stop me, little girl?\" he sneered, his voice echoing through the trees. Ella stood tall, her heart pounding with determination. Remembering Orin’s words, she whispered a spell that filled her with light. With courage in her heart, she used her cleverness and quick thinking to trick the sorcerer into believing he was surrounded by magical creatures. She conjured illusions of fierce beasts and shimmering sprites that danced around him.",
    "Confused and terrified, Malakar stumbled backward, glancing around in panic. His dark magic faltered as he struggled to comprehend the scene before him. Sensing victory, Ella and Lila combined their magic, their energies intertwining to form a protective barrier around the glade. \"The magic of friendship is stronger than any darkness!\" Ella declared, and with a final surge of power, they banished the sorcerer from the glade, his terrified screams fading into the distance.\n\nAs the sun broke through the clouds, casting golden rays over the glade, Ella was hailed as a hero. The flowers bloomed more vibrantly than ever, each petal a testament to her bravery and heart. With Lila by her side, they celebrated their victory, dancing among the blossoms, laughter echoing through the trees. The forest flourished under Lila's protection, and Ella felt a sense of belonging that she had never experienced before.\n\nFrom that day on, Ella visited Lila often, learning more about the secrets of the enchanted world. They explored hidden paths, encountered friendly creatures, and shared stories by the glimmering streams. Ella discovered that true magic resided not just in spells and charms, but in the kindness and courage one carried in their heart. Together, they forged an unbreakable bond, vowing to protect the forest and its wonders for generations to come. Whenever Ella ventured into the woods, she carried the knowledge that true strength comes from friendship, courage, and the magic that lies within us all.\n\nAnd so, the enchanted forest thrived, its beauty preserved for those who believed in the magic of nature and the power of the heart."
  ];

  @override
  void initState() {
    super.initState();
    loadUserEmail(); // Load user email from Shared Preferences
    loadBookData();
    _checkIfBookmarked(); // Load book data from the widget
  }

  Future<void> _checkIfBookmarked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('email');

    // Create a unique key for the user
    String key = '${username}_completedBooks';
    List<String> bookmarkedBooks = prefs.getStringList(key) ?? [];

    setState(() {
      isChapterCompleted =
          bookmarkedBooks.contains(json.encode(widget.bookData));
    });
  }

  Future<void> _toggleBookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('email');
    String key = '${username}_completedBooks';
    List<String> bookmarkedBooks = prefs.getStringList(key) ?? [];

    if (isChapterCompleted) {
      bookmarkedBooks.remove(json.encode(widget.bookData));
    } else {
      bookmarkedBooks.add(json.encode(widget.bookData));
    }

    await prefs.setStringList(key, bookmarkedBooks);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(isChapterCompleted
              ? 'Chapter marked as incomplete!'
              : 'Chapter marked as completed!')),
    );

    setState(() {
      isChapterCompleted = !isChapterCompleted; // Toggle the state
    });
  }

  Future<void> loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve user email
    isDarkMode = prefs.getBool('isDarkMode') ?? false; // Load dark mode state

    // Load chapter completion status from Shared Preferences
  }

  void goToNextPage() {
    if (currentPage < storyContent.length - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  void loadBookData() {
    setState(() {
      bookName = widget.bookData['title'] ?? 'Unknown';
      chapterName = "Introduction"; // Adjust as necessary
      chapterDescription =
          widget.bookData['description'] ?? 'No description available';
      bookContent = []; // Use actual content if available
      webReaderLink = widget.bookData['webReaderLink'] ?? '';
      isLoading = false;
      pages = widget.bookData['pageCount'].toString() ?? 'N/A';
      bookCover = widget.bookData != null
          ? (widget.bookData['thumbnail'] ??
              widget.bookData['imageLinks']?['thumbnail'] ??
              'assets/images/default_thumbnail.png')
          : 'assets/images/default_thumbnail.png';
    });
  }

  Future<void> openWebReader() async {
    if (await canLaunchUrl(webReaderLink as Uri)) {
      await launchUrl(webReaderLink as Uri); // Open in browser
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Web Reader Unavailable')),
      );
    }
  }

  Future<void> toggleDarkMode() async {
    setState(() {
      isDarkMode = !isDarkMode; // Toggle the dark mode state
    });

    // Save the dark mode state in Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : kScaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Center(
            child: isLoading
                ? CircularProgressIndicator() // Show loading indicator
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(bookName,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black)),
                      Text('Chapter 1: $chapterName',
                          style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.grey)),
                    ],
                  ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.dark_mode,
                  color: isDarkMode ? Colors.white : Colors.black),
              onPressed: toggleDarkMode, // Toggle dark mode on press
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading while fetching
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Card
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFEFC5C1),
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(bookCover),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Divider and Bookmark Icon
                    _buildDividerWithIcon(),
                    SizedBox(height: 16),
                    // Chapter Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        chapterDescription,
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    // Another Divider
                    _buildDividerWithIcon(),
                    SizedBox(height: 16),
                    // Book Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        storyContent[currentPage], // Simulate repeated content
                        style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed:
                              webReaderLink.isNotEmpty ? openWebReader : null,
                          child: Text(
                            webReaderLink.isNotEmpty
                                ? 'Read in Web Reader'
                                : 'Web Reader Unavailable',
                          ),
                        ),
                      ),
                    ),
                    // Divider before completion
                    _buildDividerWithIcon(),
                    SizedBox(height: 16),
                    // Completion Prompt
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Tap the check icon to mark this chapter as completed.',
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    // Web Reader Button or Unavailable Message
                    _buildDividerWithIcon(),
                  ],
                ),
              ),
        // Bottom Bar
        bottomNavigationBar: BottomAppBar(
          color: isDarkMode ? Colors.black : Colors.white,
          child: Container(
            height: 60,
            child: Row(
              children: [
                // Left Container (Home, Bookmark, Favorite)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.home,
                            color: isDarkMode ? Colors.white : Colors.black),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return HomeScreen();
                          }));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.bookmark,
                            color: isDarkMode ? Colors.white : Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookmarkScreen(fromReadingScreen: true),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isChapterCompleted
                              ? FontAwesomeIcons.circleCheck // Filled icon
                              : FontAwesomeIcons.circle,
                          size: 20,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          _toggleBookmark();
                        }, // Mark chapter as complete
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                    color: isDarkMode ? Colors.white54 : Colors.grey),
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: goToPreviousPage,
                ),
                // Right Container (Page Number, Forward Arrow)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Pg ${currentPage + 1} of $pages',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward,
                            color: isDarkMode ? Colors.white : Colors.black),
                        onPressed: goToNextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to create Divider with Circle Avatar in the middle
  Widget _buildDividerWithIcon() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDarkMode ? Colors.white54 : Colors.grey,
              thickness: 1.5,
              endIndent: 10,
            ),
          ),
          CircleAvatar(
            radius: 12,
            backgroundColor: isDarkMode ? Colors.white54 : Colors.grey,
            child: Icon(
              Icons.bookmark,
              size: 16,
              color: isDarkMode ? Colors.black54 : Colors.white,
            ),
          ),
          Expanded(
            child: Divider(
              color: isDarkMode ? Colors.white54 : Colors.grey,
              thickness: 1.5,
              indent: 10,
            ),
          ),
        ],
      ),
    );
  }
}
