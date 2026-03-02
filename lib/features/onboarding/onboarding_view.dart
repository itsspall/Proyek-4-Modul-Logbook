import 'package:flutter/material.dart';
import 'package:logbook_app_053/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _step = 0; 

  final List<String> _imagesOnboarding = [
    'assets/images/gambar_1.jpg',
    'assets/images/gambar_2.jpg',
    'assets/images/gambar_3.jpg',
  ];

  final List<String> _descriptionsOnboarding = [
    'Mulai catat setiap aktivitas harianmu dengan mudah dan cepat tanpa ribet.',
    'Lihat kembali riwayat perjalanan dan evaluasi progresmu setiap minggunya.',
    'Capai target belajarmu dan jadikan setiap langkah kecil sebagai pencapaian besar!',
  ];

  // Menampilkan gambar onboarding pertama kali agar tidak delay saat ditampilkan
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (String path in _imagesOnboarding) {
      precacheImage(AssetImage(path), context);
    }
  }

  void _nextStep() {
    if (_step < _imagesOnboarding.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _imagesOnboarding.length,
                onPageChanged: (index) {
                  setState(() {
                    _step = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _imagesOnboarding[index],
                          height: 300,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Langkah ${index + 1}",
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        Text(
                          _descriptionsOnboarding[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bagian dot indicator dan tombol next
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indikator Titik 3 (Dot Indicator)
                  Row(
                    children: List.generate(
                      _imagesOnboarding.length,
                      (index) => buildDot(index),
                    ),
                  ),

                  // Tombol Next / Start
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      elevation: 4,
                    ),
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _step == index ? 25 : 10,
      decoration: BoxDecoration(
        color: _step == index ? Colors.blue.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}