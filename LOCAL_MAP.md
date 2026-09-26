# LOCAL_MAP.md — Reconhecimento e Mapeamento da Tela "Compartilhar Foto"

## 1. Arquivo da Tela Local
- **Arquivo**: `lib/widgets/share_photo_sheet.dart`
- **Widgets e Métodos Públicos**:
  - `showSharePhotoSheet(...)`: Abre a visualização em modal sheet via `showAppSheet`.
  - `showSharePhotoScreen(...)`: Abre a visualização em tela cheia via `pushFadeSlideRoute` (transição Fade+Slide adaptada de GymMane).
  - `SharePhotoSheet`: `StatefulWidget` que renderiza o editor de fotos e stickers/marca d'água.

## 2. Call Sites Preservados (Intocados)
1. **Conclusão de Treino**: `lib/screens/session_screen.dart` (~L1217)
   ```dart
   showSharePhotoSheet(
     context,
     durationStr: durStr,
     prCount: prCount,
     volumeKg: volKg,
     calories: calories,
     muscleGroupsStr: muscles,
   );
   ```
2. **Galeria de Fotos do Treino**: `lib/screens/gallery_screen.dart` (~L611)
   ```dart
   showSharePhotoSheet(
     context,
     durationStr: '$durMins MIN',
     prCount: 0,
     volumeKg: photo.session.volume,
     calories: (durMins * 5 + photo.session.volume * 0.02).round().clamp(20, 2000),
     muscleGroupsStr: '',
     initialImageBase64: photo.data,
   );
   ```
3. **Contrato de API**:
   - Assinatura preservada: `durationStr`, `prCount`, `volumeKg`, `calories`, `muscleGroupsStr`, `initialImagePath`, `initialImageBase64`.
   - Transições de entrada (`showAppSheet` e `pushFadeSlideRoute`) permanecem inalteradas.

## 3. Diagnóstico dos Widgets e Estado Internos Atuais (A Substituir)
- **Exigência rígida de foto prévia**: A tela atual bloqueia salvar/compartilhar se não houver foto carregada (`_photoFile == null`), emitindo toast de erro. Não possui opção "Sem foto" (checkerboard).
- **Controles separados**: Utiliza slider isolado para escala (`_watermarkScale`) e pan gesture limitado (`onPanUpdate`). Não há suporte a pinça para zoom nem rotação angular contínua por gestos.
- **Estilos limitados**: Oferece apenas 3 chips de texto ("Completo", "Compacto", "Mínimo"), sem suporte aos 6 layouts visuais nem à paleta de 6 swatches de cor.
- **Sem modo de sequência**: Não possui o toggle Treino vs. Sequência (Streak) nem alternador dinâmico de exibição da data.

## 4. Análise de Dependências (`pubspec.yaml`)
- `image_picker: ^1.2.3`: **Presente** no `pubspec.yaml`.
- `share_plus: ^12.0.2`: **Presente** no `pubspec.yaml`.
- `path_provider: ^2.1.6`: **Presente** no `pubspec.yaml`.
- `phosphor_flutter: ^2.1.0`: **Presente** no `pubspec.yaml`.
- Serviço de salvamento na galeria: `saveImageToGallery(Uint8List png, String name)` já implementado em `lib/services/gallery.dart` via MethodChannel `gymmane/gallery` no `MainActivity.kt`.
- **Gaps de dependências**: Nenhum pacote novo precisa ser adicionado ao `pubspec.yaml`.

## 5. Análise de Permissões
- **Android (`android/app/src/main/AndroidManifest.xml`)**:
  - `CAMERA`: Não declarada no manifest. Necessário adicionar `<uses-permission android:name="android.permission.CAMERA" />` e `<uses-feature android:name="android.hardware.camera" android:required="false" />` para suportar `ImageSource.camera` de maneira resiliente em todas as OEMs.
  - `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE`: Declarar opcionalmente com `maxSdkVersion="32"` para compatibilidade com versões legadas do Android.
- **iOS (`ios/Runner/Info.plist`)**:
  - O projeto atual não possui diretório `ios/` (focado em Android/Linux). Caso venha a ser compilado para iOS futuramente, são necessárias as chaves `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription`.
