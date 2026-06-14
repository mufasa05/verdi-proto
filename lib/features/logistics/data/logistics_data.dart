import 'package:flutter/material.dart';

class DeliveryItem {
  final String id;
  final String customer;
  final String product;
  final String quantity;
  final String from;
  final String to;
  final String status;
  final String driver;
  final String vehicle;
  final String eta;
  final double progress;

  const DeliveryItem({
    required this.id,
    required this.customer,
    required this.product,
    required this.quantity,
    required this.from,
    required this.to,
    required this.status,
    required this.driver,
    required this.vehicle,
    required this.eta,
    required this.progress,
  });
}

class LogisticsStat {
  final String label;
  final String value;
  final IconData icon;

  const LogisticsStat({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class LogisticsMockData {
  static const deliveries = [
    DeliveryItem(
      id: '#DLV-101',
      customer: 'Tendai M.',
      product: 'Tomatoes',
      quantity: '120 kg',
      from: 'Chiredzi Farm',
      to: 'Harare Market',
      status: 'On the way',
      driver: 'Tafadzwa',
      vehicle: 'Truck ZW-21',
      eta: '1h 20m',
      progress: 0.72,
    ),
    DeliveryItem(
      id: '#DLV-102',
      customer: 'Nyasha K.',
      product: 'Maize',
      quantity: '430 kg',
      from: 'Mambo Farm',
      to: 'Masvingo Depot',
      status: 'Picked up',
      driver: 'Blessing',
      vehicle: 'Truck ZW-09',
      eta: '2h 10m',
      progress: 0.45,
    ),
    DeliveryItem(
      id: '#DLV-103',
      customer: 'J. Sibanda',
      product: 'Eggs',
      quantity: '52 trays',
      from: 'Sunrise Poultry',
      to: 'Bulawayo Center',
      status: 'Pending',
      driver: 'Moses',
      vehicle: 'Van ZW-14',
      eta: 'Today 4:30 PM',
      progress: 0.12,
    ),
    DeliveryItem(
      id: '#DLV-104',
      customer: 'Rudo P.',
      product: 'Brahman',
      quantity: '2 heads',
      from: 'Mufasa Ranch',
      to: 'Gwanda Yard',
      status: 'On the way',
      driver: 'Tafadzwa',
      vehicle: 'Truck ZW-18',
      eta: '3h 05m',
      progress: 0.64,
    ),
  ];

  static const stats = [
    LogisticsStat(
      label: 'Active',
      value: '4',
      icon: Icons.local_shipping_outlined,
    ),
    LogisticsStat(
      label: 'Picked up',
      value: '1',
      icon: Icons.inventory_2_outlined,
    ),
    LogisticsStat(
      label: 'On route',
      value: '2',
      icon: Icons.alt_route_outlined,
    ),
    LogisticsStat(
      label: 'Delayed',
      value: '0',
      icon: Icons.schedule_outlined,
    ),
  ];
}