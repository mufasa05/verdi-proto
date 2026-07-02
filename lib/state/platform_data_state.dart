import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdi/features/logistics/data/logistics_data.dart';

class OrderItem {
  final String id;
  final String buyer;
  final String product;
  final String quantity;
  final String destination;
  final String status;
  final String payment;
  final String total;
  final String date;
  final String eta;
  final String priority;

  const OrderItem({
    required this.id,
    required this.buyer,
    required this.product,
    required this.quantity,
    required this.destination,
    required this.status,
    required this.payment,
    required this.total,
    required this.date,
    required this.eta,
    required this.priority,
  });
}

class PaymentItem {
  final String id;
  final String party;
  final String type;
  final String amount;
  final String status;
  final String method;
  final String date;
  final String ref;
  final String note;

  const PaymentItem({
    required this.id,
    required this.party,
    required this.type,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
    required this.ref,
    required this.note,
  });
}

// Order State
class OrdersNotifier extends StateNotifier<List<OrderItem>> {
  OrdersNotifier()
      : super(const [
          OrderItem(
            id: '#ORD-1001',
            buyer: 'FreshMart Ltd',
            product: 'Tomatoes',
            quantity: '120 kg',
            destination: 'Harare',
            status: 'In Transit',
            payment: 'Paid',
            total: 'US\$ 96',
            date: 'Today, 09:20',
            eta: '1h 20m',
            priority: 'High',
          ),
          OrderItem(
            id: '#ORD-1002',
            buyer: 'Green Basket',
            product: 'Maize',
            quantity: '430 kg',
            destination: 'Masvingo',
            status: 'Confirmed',
            payment: 'Pending',
            total: 'US\$ 258',
            date: 'Today, 10:10',
            eta: '3h 15m',
            priority: 'Medium',
          ),
          OrderItem(
            id: '#ORD-1003',
            buyer: 'City Grocers',
            product: 'Potatoes',
            quantity: '220 kg',
            destination: 'Bulawayo',
            status: 'Delivered',
            payment: 'Paid',
            total: 'US\$ 176',
            date: 'Yesterday, 16:45',
            eta: 'Completed',
            priority: 'Low',
          ),
          OrderItem(
            id: '#ORD-1004',
            buyer: 'Hotel Supply Co',
            product: 'Mango',
            quantity: '60 crates',
            destination: 'Mutare',
            status: 'Pending',
            payment: 'Unpaid',
            total: 'US\$ 144',
            date: 'Today, 11:05',
            eta: 'Awaiting',
            priority: 'High',
          ),
        ]);

  void addOrder(OrderItem order) {
    state = [order, ...state];
  }
}

final ordersListProvider =
    StateNotifierProvider<OrdersNotifier, List<OrderItem>>((ref) {
  return OrdersNotifier();
});

// Payments State
class PaymentsNotifier extends StateNotifier<List<PaymentItem>> {
  PaymentsNotifier()
      : super(const [
          PaymentItem(
            id: '#PAY-1001',
            party: 'FreshMart Ltd',
            type: 'Buyer Payment',
            amount: 'US\$ 96',
            status: 'Completed',
            method: 'EcoCash',
            date: 'Today, 09:20',
            ref: 'TXN-8821',
            note: 'Tomatoes order',
          ),
          PaymentItem(
            id: '#PAY-1002',
            party: 'Green Basket',
            type: 'Buyer Payment',
            amount: 'US\$ 258',
            status: 'Pending',
            method: 'Bank Transfer',
            date: 'Today, 10:10',
            ref: 'TXN-8822',
            note: 'Maize order',
          ),
          PaymentItem(
            id: '#PAY-1003',
            party: 'City Grocers',
            type: 'Payout',
            amount: 'US\$ 176',
            status: 'Completed',
            method: 'Wallet',
            date: 'Yesterday, 16:45',
            ref: 'TXN-8819',
            note: 'Potatoes settlement',
          ),
          PaymentItem(
            id: '#PAY-1004',
            party: 'Hotel Supply Co',
            type: 'Buyer Payment',
            amount: 'US\$ 144',
            status: 'Failed',
            method: 'Card',
            date: 'Today, 11:05',
            ref: 'TXN-8823',
            note: 'Mango order',
          ),
        ]);

  void addPayment(PaymentItem payment) {
    state = [payment, ...state];
  }
}

final paymentsListProvider =
    StateNotifierProvider<PaymentsNotifier, List<PaymentItem>>((ref) {
  return PaymentsNotifier();
});

// Logistics Deliveries State
class DeliveriesNotifier extends StateNotifier<List<DeliveryItem>> {
  DeliveriesNotifier() : super(List.from(LogisticsMockData.deliveries));

  void addDelivery(DeliveryItem delivery) {
    state = [delivery, ...state];
  }

  void updateDeliveryStatus(String id, String status) {
    state = state.map((d) {
      if (d.id == id) {
        double progress = 0.12;
        if (status == 'Picked up') progress = 0.45;
        if (status == 'On the way') progress = 0.72;
        if (status == 'Delivered') progress = 1.0;

        return DeliveryItem(
          id: d.id,
          customer: d.customer,
          product: d.product,
          quantity: d.quantity,
          from: d.from,
          to: d.to,
          status: status,
          driver: d.driver,
          vehicle: d.vehicle,
          eta: status == 'Delivered' ? 'Delivered' : d.eta,
          progress: progress,
        );
      }
      return d;
    }).toList();
  }
}

final deliveriesListProvider =
    StateNotifierProvider<DeliveriesNotifier, List<DeliveryItem>>((ref) {
  return DeliveriesNotifier();
});
