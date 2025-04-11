import 'package:flutter/material.dart';

class XUI extends StatelessWidget {
  const XUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple,
            child: Text("H", style: TextStyle(color: Colors.white)),
          ),
        ),
        centerTitle: true,
        title: const Icon(Icons.close),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Dành cho bạn", style: TextStyle(color: Colors.white)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Đang theo dõi", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                "https://cryptologos.cc/logos/uniswap-uniswap-logo.png",
              ),
            ),
            title: Row(
              children: const [
                Text("Uniswap Labs 🦄", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 5),
                Icon(Icons.verified, size: 16, color: Colors.blue),
                SizedBox(width: 5),
                Text("@Uniswap · Quảng cáo", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            subtitle: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text("Easily access thousands of tokens across 12 chains."),
                SizedBox(height: 4),
                Text("The safe, simple way to swap on the largest onchain marketplace."),
                SizedBox(height: 12),
                Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Text("🦄 Uniswap", style: TextStyle(fontSize: 24)),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
