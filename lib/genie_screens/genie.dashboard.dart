import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../api_service.dart';

class GenieDashboard extends ConsumerStatefulWidget {
  const GenieDashboard({Key? key}) : super(key: key);

  @override
  _GenieDashboardState createState() => _GenieDashboardState();
}

class _GenieDashboardState extends ConsumerState<GenieDashboard> {
  String _selectedTab = 'new-orders';
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final apiService = ApiService();
    try {
      List<dynamic> orders;
      switch (_selectedTab) {
        case 'new-orders':
          orders = await apiService.fetchNewOrders();
          break;
        case 'ongoing-orders':
          orders = await apiService.fetchOngoingOrders();
          break;
        case 'completed-orders':
          orders = await apiService.fetchCompletedOrders();
          break;
        default:
          throw Exception('Invalid tab selected');
      }
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int orderId, String action) async {
    final apiService = ApiService();
    final error = await apiService.updateOrderStatus(orderId, action);
    if (error == null) {
      _fetchOrders();
    } else {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Genie Dashboard',
          style: TextStyle(
            fontFamily: 'San Francisco',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? Center(
        child: CupertinoActivityIndicator(
          radius: 20,
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : _buildOrderList(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildDrawerItem('New Orders', Icons.new_releases, 'new-orders'),
          _buildDrawerItem('Ongoing Orders', Icons.autorenew, 'ongoing-orders'),
          _buildDrawerItem('Completed Orders', Icons.check_circle, 'completed-orders'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, String tab) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'San Francisco',
          fontSize: 16,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
        Navigator.pop(context);
        _fetchOrders();
      },
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order['id']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                const SizedBox(height: 8),
                _buildOrderDetailRow('Items', '${order['order_items']}'),
                _buildOrderDetailRow('Customer', '${order['address']['first_name']} ${order['address']['last_name']}'),
                _buildOrderDetailRow('Address', '${order['address']['street_address']}, ${order['address']['city']}'),
                _buildOrderDetailRow('Phone', '${order['address']['phone']}'),
                _buildOrderDetailRow('Supermarket', '${order['supermarket']['name']}'),
                const SizedBox(height: 8),
                _buildActionButtons(order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic order) {
    List<Widget> buttons = [];
    if (_selectedTab == 'new-orders') {
      buttons = [
        _buildActionButton('Accept', Colors.green, () => _updateOrderStatus(order['id'], 'accept')),
        _buildActionButton('Decline', Colors.red, () => _updateOrderStatus(order['id'], 'decline')),
      ];
    } else if (_selectedTab == 'ongoing-orders') {
      buttons = [
        _buildActionButton('Complete', Colors.blue, () => _updateOrderStatus(order['id'], 'complete')),
        _buildActionButton('Fail', Colors.red, () => _updateOrderStatus(order['id'], 'fail')),
      ];
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: buttons,
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}