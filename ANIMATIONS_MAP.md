# ANIMATIONS_MAP.md — Mapa Detalhado das Animações Extraídas

Este documento detalha as características cinemáticas (tipo, duração, curvas, triggers e transformações) de cada uma das animações de transição de tela e componentes portados da origem (`InlitX/GymMane`).

---

## 1. Shell Route Switcher (`_animatedScreen`)
- **Arquivo Extraído**: `extracted/app_shell_transition.dart` (`ShellRouteSwitcher`)
- **Origem**: `lib/app/app_shell.dart:284-330`
- **Tipo**: `AnimatedSwitcher` multidirecional com blur decal, shift, scale e fade.
- **Trigger**: Mudança na propriedade `fit.route` no App Shell.
- **Duração**:
  - Transição completa: `380ms`
- **Curvas**:
  - Entrada (`switchInCurve`): `Interval(0.3, 1.0, curve: Curves.easeOutCubic)`
  - Saída (`switchOutCurve`): `Interval(0.7, 1.0, curve: Curves.easeInCubic)`
- **Eixos & Transformações**:
  - Direção: calculada dinamicamente com base na navegação lateral (índice da aba) vs navegação vertical (profundidade da rota).
  - Shift lateral: `(incoming ? 26 : -18) * dir * (1 - v)`
  - Shift vertical: `(incoming ? 22 : -8) * dir * (1 - v)`
  - Desfoque progressivo: `ImageFilter.blur(sigmaX: 10 * (1 - v), sigmaY: 10 * (1 - v), tileMode: TileMode.decal)`
  - Escala: `incoming ? 1 + 0.03 * (1 - v) : 1 - 0.04 * (1 - v)`
  - Opacidade: `v.clamp(0.0, 1.0)`

---

## 2. Liquid Pill Navigation Indicator (`_LiquidPill`)
- **Arquivo Extraído**: `extracted/app_shell_transition.dart` (`LiquidPillIndicator`)
- **Origem**: `lib/app/app_shell.dart:654-705`
- **Tipo**: Indicador animado com física de esticamento (squash) e elevação iluminada.
- **Trigger**: Troca de aba selecionada ou arraste na bottom navigation bar.
- **Duração**:
  - Movimento horizontal (`_move`): `460ms`
  - Elevação e brilho (`_lift`): `260ms` (avanço) / `380ms` (reverso)
- **Curvas**:
  - Lead: `Curves.easeOutCubic`
  - Trail: `Curves.easeInOutCubic`
  - Lift: `Cubic(0.3, 1.25, 0.5, 1.0)` (efeito elástico overshoot)
- **Transformações**:
  - Deformação de largura/squash: `squash = 1 - 0.14 * (1 - (2 * t - 1).abs())`
  - Expansão de raio: `grow = 6 * lift`
  - Sombra dinâmica no lift: `BoxShadow(blurRadius: 18 * lift, spreadRadius: 2 * lift)`

---

## 3. Glass Dialog & Sheet PageRoute (`_GlassDialogRoute` / `_GlassSheetRoute`)
- **Arquivo Extraído**: `extracted/glass_route.dart` (`GlassDialogRoute`, `GlassSheetRoute`, `BlurBarrier`)
- **Origem**: `lib/widgets/glass.dart:14-98`
- **Tipo**: `DialogRoute` / `ModalBottomSheetRoute` com barreira desfocada e transição elástica.
- **Trigger**: Invocação de modais centrais (`showAppDialog`) ou painéis inferiores (`showAppSheet`).
- **Duração**:
  - Duração padrão de rota modal do Flutter (`300ms` forward / `250ms` reverse)
- **Curvas**:
  - Escala entrada: `Curves.easeOutBack`
  - Escala saída: `Curves.easeInCubic`
  - Fade e desfoque da barreira: `Curves.easeOut`
- **Transformações**:
  - Escala do conteúdo: `Tween<double>(begin: 0.92, end: 1.0)`
  - Desfoque da barreira: `BackdropFilter` sigma de `0` até `14.0` (`kSheetBlur`)

---

## 4. Full-screen Photo Hero Viewer (`_PhotoView`)
- **Arquivo Extraído**: `extracted/moments_photo_hero.dart` (`PhotoHeroViewer`, `openPhotoHeroViewer`)
- **Origem**: `lib/screens/moments_screen.dart:55, 185, 283`
- **Tipo**: Rota transparente sobreposta com expansão `Hero` e desfoque dinâmico.
- **Trigger**: Toque em qualquer miniatura de foto de progresso/treino na galeria.
- **Duração**:
  - Abertura: `280ms`
  - Fechamento: `220ms`
- **Curvas**:
  - `Curves.easeOutCubic`
- **Transformações**:
  - `BackdropFilter` de fundo: sigma progressivo `0` → `20.0 * v`
  - `Hero` conectando miniatura com foto central (arredondamento `22px`)
  - Fade dos controles (data, botões e cabeçalho): `Opacity(v)`

---

## 5. Modal / Sheet Fade+Slide Route (`StickerEditor` route)
- **Arquivo Extraído**: `extracted/sticker_fade_slide_route.dart` (`FadeSlidePageRoute`)
- **Origem**: `lib/screens/sticker_screen.dart:23-31`
- **Tipo**: `PageRouteBuilder` de tela cheia / editor com deslocamento suave vertical e desvanecimento.
- **Trigger**: Abertura de telas de edição, compartilhamento ou configuração.
- **Duração**:
  - Transição de entrada: `340ms`
  - Transição de saída: `240ms`
- **Curvas**:
  - `Curves.easeOutCubic`
- **Transformações**:
  - Slide vertical: `Tween<Offset>(begin: Offset(0, 0.04), end: Offset.zero)`
  - Opacidade: `0.0` → `1.0`

---

## 6. Media / Note Full-screen Viewer (`showNoteMedia`)
- **Arquivo Extraído**: `extracted/note_media_viewer.dart` (`GenericMediaViewer`, `showGenericMediaViewer`)
- **Origem**: `lib/widgets/note_kit.dart:578-691`
- **Tipo**: `PageRouteBuilder` não-opaco com dismiss por toque na barreira escura, `InteractiveViewer` e `PageView`.
- **Trigger**: Abertura de anexos de notas, mídia ou múltiplas fotos de exercícios.
- **Duração**:
  - Abertura: `360ms`
  - Fechamento: `300ms`
- **Curvas**:
  - `Curves.easeOut`
- **Transformações**:
  - `FadeTransition` completa na barreira preta `0xF2000000`
  - `InteractiveViewer` com `maxScale: 5`

---

## 7. Staggered Entrance Animations (`Rise` & `RiseScope`)
- **Arquivo Extraído**: `extracted/session_rise_and_slider.dart` (`Rise`, `riseAll`)
- **Origem**: `lib/widgets/entrance.dart:58-115` (aplicado em `session_screen.dart:1139-1230`)
- **Tipo**: Entrada escalonada por índice para grupos de cartões/widgets.
- **Trigger**: Renderização da tela de resumo de treino concluído (`_complete`).
- **Duração**:
  - Atraso inicial por índice: `40ms + (index * 70ms)` (com clamp em até 8 itens)
  - Tempo de movimento: `560ms`
  - Duração total do controller: `delay + 560ms`
- **Curvas**:
  - `Interval(delay / (delay + motion), 1.0, curve: Curves.easeOutCubic)`
- **Transformações**:
  - Deslocamento vertical: `Transform.translate(offset: Offset(0, 22 * (1 - v)))`
  - Escala: `Transform.scale(scale: 0.97 + 0.03 * v)`
  - Opacidade: `Opacity(v)`

---

## 8. Session Exercise Slider Transition (`_ExerciseSlider`)
- **Arquivo Extraído**: `extracted/session_rise_and_slider.dart` (`ExerciseSlideTransition`)
- **Origem**: `lib/screens/session_screen.dart:1504-1525`
- **Tipo**: `AnimatedSwitcher` horizontal com slide relativo, zoom e desvanecimento.
- **Trigger**: Troca de exercício durante uma sessão ativa de treino.
- **Duração**:
  - `520ms`
- **Curvas**:
  - Entrada: `Interval(0.3, 1.0, curve: Curves.easeOutCubic)`
  - Saída: `Interval(0.55, 1.0, curve: Curves.easeInCubic)`
- **Transformações**:
  - Deslocamento horizontal: `Tween<Offset>(begin: Offset(0.5 * dir, 0), end: Offset.zero)` (onde `dir` é `1` se avanço ou `-1` se retorno)
  - Escala: `Tween<double>(begin: 0.94, end: 1.0)`
  - Fade: `FadeTransition(opacity: animation)`

---

## 9. Wear OS Shell Transition & Wear Session Slider
- **Arquivo Extraído**: `extracted/wear_shell_transition.dart` (`WearShellScreenSwitcher`, `WearSessionSliderTransition`)
- **Origem**: `lib/wear/wear_shell.dart:175, 1245`
- **Tipo**: Transições ultraleves para smartwatch.
- **Trigger**: Navegação no app Wear OS.
- **Duração**:
  - Shell geral: `220ms`
  - Slider de sessão: `420ms`
- **Curvas**:
  - `Interval(0.3, 1.0, Curves.easeOutCubic)` e `Interval(0.55, 1.0, Curves.easeInCubic)`
- **Transformações**:
  - Slide horizontal de `0.4 * dir` + Fade.

---

## 10. Rolling Text, Digit Wheels & Text Switcher
- **Arquivo Extraído**: `extracted/radar_and_rolling_text.dart` (`RollingText`, `RollInCounter`, `SubtleTextSwitcher`)
- **Origem**: `lib/widgets/muscle_radar.dart:100-105` e `lib/widgets/rolling_text.dart:1-160`
- **Tipo**: Odômetro e animações numéricas microinterativas.
- **Trigger**: Mudança de valores de repetição, peso, cronômetro ou legendas de músculos.
- **Duração**:
  - Legenda sutil: `220ms` Fade
  - Rolo por dígito (`RollingText`): `420ms` por alteração, `240ms` de redimensionamento (`AnimatedSize`)
  - Contador ascendente (`RollInCounter`): `1150ms`
- **Curvas**:
  - Rotação do dígito: `Curves.easeOutCubic` (entrada) / `Curves.easeInCubic` (saída)
  - `Curves.easeOutCubic` para o redimensionador e contador ascendente.
