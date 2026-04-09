import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../Exception/AppException.dart';
import '../../Exception/NoInternetConnectionException.dart';
import '../../Exception/ProductNotFoundException.dart';

class DeleteProductPopup extends StatelessWidget {
  final String productId;
  final String name;

  const DeleteProductPopup({
    super.key,
    required this.productId,
    required this.name
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ProductService _productService = ProductService();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (Colors.red).withOpacity(0.1),
                //shape: BoxCircle(),
              ),
              child: Icon(
                Icons.delete,
                color:Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),


            Text(
              "Voulez vous vraiment supprimer le produit $name ?",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Annuler", style: TextStyle(color: Colors.grey[600])),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try{
                        await _productService.deleteProduct(productId);

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          title: "Succes",
                          desc: "Produit supprimer avec succes",
                          btnOkText: "OK",
                          btnOkColor: Colors.green
                        ).show();

                      } on NoInternetConnectionException catch(e){

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          title: "Erreur Reseau",
                          desc: e.message,
                          btnOkText: "OK",
                          btnOkColor: colorScheme.error,
                        ).show();

                      } on ProductNotFoundException catch(e){

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          title: "Erreur",
                          desc: e.message,
                          btnOkText: "OK",
                          btnOkColor: colorScheme.error,
                        ).show();

                      } on AppException catch(e){

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          title: "Erreur",
                          desc: e.message,
                          btnOkText: "OK",
                          btnOkColor: colorScheme.error,
                        ).show();

                      }on DioException catch(e) {

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          title: "Erreur inattendue",
                          desc: e.message,
                          btnOkText: "OK",
                          btnOkColor: colorScheme.error,
                        ).show();

                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text("Supprimer"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}