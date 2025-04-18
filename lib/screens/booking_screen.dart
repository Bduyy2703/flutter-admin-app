class BookingManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý Đơn hàng')),
      body: ListView.builder(
        itemCount: 10, // Thay bằng dữ liệu từ API
        itemBuilder: (context, index) => ListTile(
          title: Text('Đơn hàng $index'),
          subtitle: Text('Trạng thái: PENDING'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: Icon(Icons.check), onPressed: () {}),
              IconButton(icon: Icon(Icons.cancel), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}