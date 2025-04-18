class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cài đặt')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(decoration: InputDecoration(labelText: 'Email')),
          TextField(decoration: InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
          ElevatedButton(onPressed: () {}, child: Text('Lưu')),
        ],
      ),
    );
  }
}