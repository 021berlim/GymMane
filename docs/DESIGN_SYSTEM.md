# GymMane — Design System

Documento canônico de padrões visuais, tokens e componentes do **GymMane**, alinhado à referência visual móvel (*"Monte seu treino"*).

---

## 1. Princípios Fundamentais

1. **Mínima Intervenção:** Corrigir na raiz (tokens e componentes canônicos) para propagar automaticamente às telas sem alterar regras de negócio, fluxos ou rotas.
2. **Alto Contraste & Dark UI:** Fundo escuro profundo, superfícies cinza discretas com elevação tonal e bordas sutis de 1px. Sem sombras difusas que prejudiquem a visibilidade sob iluminação de treino.
3. **Ergonomia Mobile-First:** Tap targets mínimos de 48x48dp, respeito absoluto à `SafeArea` inferior em ações fixas de rodapé e navegação rápida na *Thumb Zone*.

---

## 2. Regra de Cores: Branco vs Verde

| Elemento / Papel | Token | Aplicação Visual | Justificativa de UX |
| :--- | :--- | :--- | :--- |
| **CTA Primário** | `gc.ember` (`#FFFFFF`) | Fundo do botão principal de ação (Start, Salvar, Continuar). Texto em `gc.onEmber` (`#0A0A0A`). | Máximo contraste (>15:1), reconhecimento imediato em academias, não cansa a visão. |
| **Acento & Identidade** | `gc.accent` (`#A3E635` / `#4D7C0F`) | Eyebrows, progresso, sparklines/gráficos, PRs/conquistas, badges de status, logo e ícones em foco. | Destaca dados de telemetria e rendimento sem competir visualmente com a ação primária. |
| **Destrutivo / Erro** | `gc.danger` (`#E5674C` / `#C0392B`) | Ações de exclusão, alertas de descarte, confirmações críticas e toasts de erro. | Fonte única da verdade para ações destrutivas (nunca usar verde para confirmar exclusão). |
| **Secundário / Ghost** | `gc.bgRaised2` / Outline | Botões secundários, filtros inativos e ações neutras. | Mantém a hierarquia clara sem poluir o campo visual. |

---

## 3. Tokens de Design

### 3.1 Cores (`GymColors`)

```dart
// Dark Theme (Padrão)
pageBg:       Color(0xFF090B08) // Fundo profundo de página
bg:           Color(0xFF0A0A0A) // Fundo base do canvas
bgRaised:     Color(0xFF161616) // Superfície 1 (Cards, Headers, Bottom Sheets)
bgRaised2:    Color(0xFF202020) // Superfície 2 (Chips, Inputs inativos, Steppers)
border:       Color(0xFF2A2A2A) // Borda sutil de 1px
text:         Color(0xFFFFFFFF) // Texto primário de alto contraste
textSecondary:Color(0xFF9A9A9A) // Subtítulos, metadados e legendas
textTertiary: Color(0xFF8A8A8A) // Acessibilidade WCAG AA (>= 4.5:1 sobre superfícies escuras)
ember:        Color(0xFFFFFFFF) // Branco de ação primária e seleção
onEmber:      Color(0xFF0A0A0A) // Texto preto sobre botão/check branco
accent:       Color(0xFFA3E635) // Verde limão oficial (Tailwind Lime-400)
brass:        Color(0xFFBEF264) // Verde limão claro (Lime-300) para eyebrows/destaques
danger:       Color(0xFFE5674C) // Coral para exclusão e erro (Dark)
```

### 3.2 Raios de Borda (`AppRadius`)

```dart
class AppRadius {
  static const double sm = 8.0;      // Badges pequenas, botões compactos
  static const double md = 14.0;     // Inputs, containers intermediários
  static const double card = 16.0;   // Cards padrão, linhas de exercícios, tiles
  static const double sheet = 28.0;  // Cantos superiores de modais e bottom sheets
  static const double pill = 100.0;  // Botões primários, chips, toggles, barras de busca
}
```

### 3.3 Tipografia (`AppTheme`)

- **Display / Números / Títulos:** Família `Oswald` (`AppTheme.disp`).
  - **Títulos de Tela:** `AppTheme.d(20..22, weight: FontWeight.w700, letterSpacing: 1.5..2)` em **CAIXA ALTA**.
  - **Eyebrows / Kickers:** `AppTheme.d(11..12, weight: FontWeight.w600, color: gc.brass, letterSpacing: 2..3)` em **CAIXA ALTA**.
  - **Labels de Seção:** `AppTheme.d(11..12, weight: FontWeight.w700, color: gc.textSecondary, letterSpacing: 1)` em **CAIXA ALTA**.
  - **Valores Numéricos de Performance:** `AppTheme.d(size, weight: FontWeight.w700)`.
- **Sans / Texto Corrido / Detalhes:** Família `IBM Plex Sans` (`AppTheme.sans`).
  - **Texto Principal:** `AppTheme.s(14, weight: FontWeight.w600, color: gc.text)`.
  - **Texto Secundário / Descrições:** `AppTheme.s(12..13, weight: FontWeight.w400, color: gc.textSecondary)`.

---

## 4. Componentes Canônicos

### 4.1 `PrimaryButton` (Ação Principal)
- **Geometria:** Altura **56px**, largura total (`double.infinity`), formato **Pill** (`borderRadius: 100`).
- **Cores:** Fundo branco `gc.ember`, texto e ícone pretos `gc.onEmber`.
- **Tipografia:** `AppTheme.d(16, weight: FontWeight.w600, letterSpacing: 2)` em **CAIXA ALTA**.
- **Estados:** `enabled`, `isLoading` (com spinner acessível), `disabled` (fundo `gc.bgRaised2`, texto `gc.textTertiary`, sem disparar clique).
- **Rodapé:** Quando fixo no rodapé, envolvido em container com `gc.bgRaised`, borda superior `gc.border` e `SafeArea(bottom: true)`.

### 4.2 `RoundBtn` (Ações Circulares de Navegação)
- **Geometria:** Visual circular de 36x36px, com **área de toque acessível de 48x48dp**.
- **Cores:** Fundo `gc.bgRaised`, borda `gc.border`, ícone `gc.text`.
- **Suporte a Ícones:** Aceita `IconData` (Phosphor), `List<IconPath>` ou `Widget`.

### 4.3 `AppSearchBar` (Busca Padronizada)
- **Geometria:** Altura **48px**, formato **Pill** (`borderRadius: 100`), padding horizontal 16px.
- **Cores:** Fundo `gc.bgRaised`, borda `gc.border`.
- **Elementos:** Ícone de lupa à esquerda (`gc.textSecondary`), campo de texto com hint `AppTheme.s(14, color: gc.textSecondary)`, e botão de limpar ("X") à direita quando preenchido.

### 4.4 `SoftCard` (Card de Conteúdo)
- **Geometria:** Raio canônico de **16px**, padding padrão 16 a 20px.
- **Cores:** Fundo `gc.bgRaised`, borda sutil de 1px `gc.border`.

### 4.5 `SelectableCardTile` / Item de Lista Selecionável
- **Geometria:** Raio **16px**, padding 14px, fundo `gc.bgRaised`.
- **Estado Normal:** Borda sutil `gc.border`. Checkbox lateral circular com borda cinza.
- **Estado Selecionado:** Borda branca `gc.ember` de 1.5px. Checkbox lateral circular preenchido em branco `gc.ember` com ícone de check preto `gc.onEmber`.

### 4.6 `SegToggle` / Chips
- **Geometria:** Formato **Pill** (`borderRadius: 100`), fundo `gc.bgRaised2`.
- **Estado Ativo:** Fundo `gc.ember` (branco), texto `gc.onEmber` (preto).
- **Estado Inativo:** Fundo transparente, texto `gc.textSecondary`.

### 4.7 `ScreenHeader` (Cabeçalho de Telas Secundárias)
- **Estrutura:** `RoundBtn` de retorno + `ScreenTitle` em **CAIXA ALTA** + opcional `subtitle` + ações na extremidade direita.

### 4.8 `EmptyStateView` & Feedback
- **Estado Vazio:** Ícone centralizado em `gc.textTertiary`, título em `AppTheme.d(16, w700, gc.text)`, subtítulo descritivo em `AppTheme.s(13, gc.textSecondary)`, e botão de ação opcional.
- **Toasts:** Utilização estrita do `AppToast` (`lib/widgets/app_toast.dart`), eliminando `SnackBar` nativas desformatadas.
- **Exclusões:** Diálogo unificado `showConfirmDeleteModal` com botão de confirmação em vermelho `gc.danger`.
