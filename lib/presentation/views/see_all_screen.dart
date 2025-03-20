import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/OvalsPainter.dart';
import '../widgets/card.dart';
import '../view_models/see_all_view_model.dart';

class SeeAllScreen extends StatelessWidget {
  const SeeAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SeeAllViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con los círculos superpuestos
          Positioned.fill(
            child: CustomPaint(
              painter: OvalsPainter(),
            ),
          ),

          // Título "Buildings" sobre el fondo
          Positioned(
            top: 50,  
            left: MediaQuery.of(context).size.width / 2 - 65,  
            child: Text(
              "Buildings",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Contenido principal con desplazamiento para evitar overflow
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 120), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de búsqueda con fondo blanco y texto negro
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Where to go?",
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white, 
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.filter_alt_outlined),
                      ),
                    ),
                  ),

                  // Espacio entre la búsqueda y la cuadrícula
                  const SizedBox(height: 20),

                  // Contenedor con la cuadrícula de edificios o indicador de carga
                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator()) // Mostramos un loading mientras carga
                        : viewModel.error != null
                            ? Center(child: Text(viewModel.error!)) // Si hay error, lo mostramos
                            : GridView.builder(
                                padding: const EdgeInsets.all(16.0),
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                ),
                                itemCount: viewModel.buildings.length,
                                itemBuilder: (context, index) {
                                  final building = viewModel.buildings[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // Navega a la pantalla de detalles con los datos de Supabase
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CardScreen(buildingIndex: index),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      child: Column(
                                        children: [
                                          // Imagen desde Supabase o placeholder si no hay
                                          Container(
                                            height: 120,
                                            decoration: BoxDecoration(
                                              image: building['image_url'] != null
                                                  ? DecorationImage(
                                                      image: NetworkImage(building['image_url']),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                              color: building['image_url'] == null ? Colors.grey[300] : null,
                                            ),
                                            child: building['image_url'] == null
                                                ? const Icon(Icons.image, size: 50)
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            building['name'],
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            building['description'] ?? 'Sin descripción',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
