import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_strings.dart';
import '../../common/macos_toolbar.dart';
import '../widgets/one_pager_pdf.dart';

class OnePagerScreen extends StatelessWidget {
  const OnePagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MacosToolbar(
        title: AppStrings.onePager,
        actions: [
          Semantics(
            label: AppStrings.onePagerShare,
            child: IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                final bytes = await buildOnePagerPdf();
                await Printing.sharePdf(bytes: bytes, filename: 'talon-one-pager.pdf');
              },
            ),
          ),
          Semantics(
            label: AppStrings.print,
            child: IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                final bytes = await buildOnePagerPdf();
                await Printing.sharePdf(bytes: bytes, filename: 'talon-one-pager.pdf');
              },
            ),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) => buildOnePagerPdf(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: 'talon-one-pager.pdf',
      ),
    );
  }
}
