import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import 'weather_provider.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeatherProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Weather')),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.weather == null
            ? Center(
                child: Text(
                  state.error ?? 'No weather data available',
                  style: GoogleFonts.poppins(),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1100;
                    final weather = state.weather!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WeatherHeroCard(weather: weather),
                        const SizedBox(height: 16),
                        _WeatherAlertCard(alerts: weather.alerts),
                        const SizedBox(height: 16),
                        _SectionTitle(
                          title: 'Current conditions',
                          actionText: 'Refresh',
                          onTap: state.loadWeather,
                        ),
                        const SizedBox(height: 12),
                        _CurrentConditionsGrid(weather: weather),
                        const SizedBox(height: 16),
                        _SectionTitle(
                          title: 'Hourly forecast',
                          actionText: 'See all',
                          onTap: () {},
                        ),
                        const SizedBox(height: 12),
                        _HourlyForecastList(hours: weather.hourly),
                        const SizedBox(height: 16),
                        _SectionTitle(
                          title: '7-day outlook',
                          actionText: 'Open details',
                          onTap: () {},
                        ),
                        const SizedBox(height: 12),
                        if (isWide)
                          _WeeklyForecastWide(days: weather.daily)
                        else
                          _WeeklyForecastList(days: weather.daily),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _WeatherHeroCard extends StatelessWidget {
  final WeatherData weather;

  const _WeatherHeroCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_outlined, color: Colors.white, size: 54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.location,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.summary,
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${weather.temperature}°C',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Feels like ${weather.feelsLike}°C',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherAlertCard extends StatelessWidget {
  final List<WeatherAlert> alerts;

  const _WeatherAlertCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final alert = alerts.first;

    return Material(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${alert.title}: ${alert.message}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View alerts')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;

  const _SectionTitle({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton(onPressed: onTap, child: Text(actionText)),
      ],
    );
  }
}

class _CurrentConditionsGrid extends StatelessWidget {
  final WeatherData weather;

  const _CurrentConditionsGrid({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _ConditionCard(
          title: 'Temperature',
          value: '${weather.temperature}°C',
          icon: Icons.thermostat_outlined,
        ),
        _ConditionCard(
          title: 'Humidity',
          value: '${weather.humidity}%',
          icon: Icons.water_drop_outlined,
        ),
        _ConditionCard(
          title: 'Wind',
          value: '${weather.windSpeed} km/h',
          icon: Icons.air_outlined,
        ),
        _ConditionCard(
          title: 'Pressure',
          value: '${weather.pressure} hPa',
          icon: Icons.speed_outlined,
        ),
        _ConditionCard(
          title: 'Rain chance',
          value: '${weather.rainChance}%',
          icon: Icons.umbrella_outlined,
        ),
        _ConditionCard(
          title: 'Visibility',
          value: '${weather.visibility} km',
          icon: Icons.visibility_outlined,
        ),
      ],
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ConditionCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey.shade600),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> hours;

  const _HourlyForecastList({required this.hours});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 135,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = hours[index];
          return _HourTile(
            time: item.time,
            temp: '${item.temperature}°C',
            condition: item.condition,
          );
        },
      ),
    );
  }
}

class _HourTile extends StatelessWidget {
  final String time;
  final String temp;
  final String condition;

  const _HourTile({
    required this.time,
    required this.temp,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.cloud_outlined;
    Color color = Colors.blueGrey;

    if (condition == 'Rain') {
      icon = Icons.water_drop_outlined;
      color = Colors.blue;
    } else if (condition == 'Storm') {
      icon = Icons.thunderstorm_outlined;
      color = Colors.deepPurple;
    }

    return Container(
      width: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(temp, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WeeklyForecastList extends StatelessWidget {
  final List<DailyForecast> days;

  const _WeeklyForecastList({required this.days});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: days
          .map(
            (day) => _DailyForecastTile(
              day: day.day,
              min: '${day.minTemp}°',
              max: '${day.maxTemp}°',
              condition: day.condition,
            ),
          )
          .toList(),
    );
  }
}

class _WeeklyForecastWide extends StatelessWidget {
  final List<DailyForecast> days;

  const _WeeklyForecastWide({required this.days});

  @override
  Widget build(BuildContext context) {
    final split = (days.length / 2).ceil();
    final left = days.take(split).toList();
    final right = days.skip(split).toList();

    return Row(
      children: [
        Expanded(
          child: Column(
            children: left
                .map(
                  (day) => _DailyForecastTile(
                    day: day.day,
                    min: '${day.minTemp}°',
                    max: '${day.maxTemp}°',
                    condition: day.condition,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: right
                .map(
                  (day) => _DailyForecastTile(
                    day: day.day,
                    min: '${day.minTemp}°',
                    max: '${day.maxTemp}°',
                    condition: day.condition,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DailyForecastTile extends StatelessWidget {
  final String day;
  final String min;
  final String max;
  final String condition;

  const _DailyForecastTile({
    required this.day,
    required this.min,
    required this.max,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.cloud_outlined;
    Color color = Colors.blueGrey;

    if (condition == 'Rain') {
      icon = Icons.water_drop_outlined;
      color = Colors.blue;
    } else if (condition == 'Sunny') {
      icon = Icons.wb_sunny_outlined;
      color = Colors.orange;
    } else if (condition == 'Storm') {
      icon = Icons.thunderstorm_outlined;
      color = Colors.deepPurple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              day,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              condition,
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
          ),
          Text(
            '$min / $max',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
