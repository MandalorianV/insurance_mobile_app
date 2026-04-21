import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view_mixin.dart';

class InsuranceView extends StatefulWidget {
  const InsuranceView({super.key});

  @override
  State<InsuranceView> createState() => _InsuranceViewState();
}

class _InsuranceViewState extends State<InsuranceView> with InsuranceViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Insurance Dashboard')),
      body: Expanded(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            shrinkWrap: false,
            itemCount: 20,
            itemBuilder: (context, index) {
              return cardView(index);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<InsuranceBloc>().add(GetInsuranceListEvent());
          //context.go('/claim');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget cardView(int index) => Card(
    margin: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          height: 30,

          child: Center(child: Text('Insurance $index')),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Mehmet Akif Sayrım"),
              Text("Poliçe No : 123456789"),
              Text("Durum : Aktif"),
              Text("Bitiş Tarihi : 31.12.2024"),
            ],
          ),
        ),
      ],
    ),
  );
}
