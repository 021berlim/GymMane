import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 1. Credenciais e Headers
final apiKeys = [
  Platform.environment['RAPIDAPI_KEY_1'] ?? '',
  Platform.environment['RAPIDAPI_KEY_2'] ?? '',
  Platform.environment['RAPIDAPI_KEY_3'] ?? '',
  Platform.environment['RAPIDAPI_KEY'] ?? '',
].where((k) => k.isNotEmpty).toList();
const apiHost = 'exercisedb.p.rapidapi.com';

/// Gerenciador de Chaves para Round-Robin e failover automático
class ApiKeyManager {
  final List<String> keys;
  int _currentIndex = 0;

  ApiKeyManager(this.keys);

  int get currentIndex => _currentIndex;
  String get currentKey => keys.isEmpty ? '' : keys[_currentIndex];
  int get keyNumber => keys.isEmpty ? 0 : _currentIndex + 1;

  /// Rotaciona para a próxima chave (Round-Robin)
  void rotate() {
    if (keys.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % keys.length;
    }
  }

  /// Retorna os headers apropriados para a requisição
  Map<String, String> getHeadersForUrl(String url) {
    final uri = Uri.tryParse(url);
    final headers = <String, String>{};
    if (uri != null && (uri.host.contains('rapidapi.com') || uri.host == apiHost)) {
      headers['x-rapidapi-key'] = currentKey;
      headers['x-rapidapi-host'] = apiHost;
    }
    return headers;
  }
}

Future<void> main(List<String> args) async {
  stdout.writeln('====================================================');
  stdout.writeln('  ExerciseDB CLI Downloader - Sincronização Autônoma');
  stdout.writeln('====================================================\n');

  final outputDir = Directory('novas_imagens');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
    stdout.writeln('[Diretório] Pasta "novas_imagens" criada com sucesso.');
  } else {
    stdout.writeln('[Diretório] Pasta "novas_imagens" detectada.');
  }

  final metadataFile = File('${outputDir.path}/exercicios_metadados.json');
  final bool forceRefresh = args.contains('--force-refresh');

  if (apiKeys.isEmpty && (!metadataFile.existsSync() || forceRefresh)) {
    stdout.writeln('[Erro] Nenhuma chave do RapidAPI configurada.');
    stdout.writeln('Defina a variável de ambiente RAPIDAPI_KEY antes de executar.');
    exit(1);
  }

  final keyManager = ApiKeyManager(apiKeys);
  final client = http.Client();

  List<Map<String, dynamic>> allExercises = [];

  try {
    // -------------------------------------------------------------
    // FASE 1: Coleta de Metadados com Paginação e Rotação de Chaves
    // -------------------------------------------------------------
    if (metadataFile.existsSync() && !forceRefresh) {
      try {
        final content = await metadataFile.readAsString();
        final decoded = jsonDecode(content);
        if (decoded is List && decoded.isNotEmpty) {
          allExercises = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          stdout.writeln(
            '\n[Cache Local] Arquivo "exercicios_metadados.json" encontrado com ${allExercises.length} exercícios.',
          );
          stdout.writeln('Passe o argumento "--force-refresh" se desejar re-consultar a API do zero.');
        }
      } catch (e) {
        stdout.writeln('[Aviso] Falha ao ler JSON local existente. Re-consultando API...');
        allExercises = [];
      }
    }

    if (allExercises.isEmpty) {
      stdout.writeln('\n--- FASE 1: Coletando Catálogo de Exercícios via RapidAPI ---');
      allExercises = await _fetchAllExercises(client, keyManager);

      // Salva metadados consolidados imediatamente após a paginação
      await _saveMetadataJson(metadataFile, allExercises);
      stdout.writeln(
        '\n[Metadados Salvos] ${allExercises.length} exercícios gravados em "${metadataFile.path}".',
      );
    }

    // -------------------------------------------------------------
    // FASE 2: Download Sequencial Idempotente de Mídias (GIFs)
    // -------------------------------------------------------------
    stdout.writeln('\n--- FASE 2: Sincronizando GIFs dos Exercícios ---');
    await _downloadGifs(client, keyManager, outputDir, allExercises);

    // Atualiza metadados consolidados ao final para garantir consistência
    await _saveMetadataJson(metadataFile, allExercises);

    stdout.writeln('\n====================================================');
    stdout.writeln('  Sincronização Concluída com Sucesso!');
    stdout.writeln('  Total de Exercícios: ${allExercises.length}');
    stdout.writeln('  Pasta de Destino: ${outputDir.absolute.path}');
    stdout.writeln('  Metadados Consolidados: ${metadataFile.path}');
    stdout.writeln('====================================================');
  } catch (e, stack) {
    stderr.writeln('\n[ERRO CRÍTICO]: $e');
    stderr.writeln(stack);
    exitCode = 1;
  } finally {
    client.close();
  }
}

/// Pagina de 10 em 10 até o fim do catálogo, rotacionando chaves a cada requisição
Future<List<Map<String, dynamic>>> _fetchAllExercises(
  http.Client client,
  ApiKeyManager keyManager,
) async {
  final List<Map<String, dynamic>> exercises = [];
  const int limit = 10;
  int offset = 0;

  while (true) {
    final batch = await _fetchPageWithRetry(client, keyManager, offset, limit);

    if (batch == null || batch.isEmpty) {
      stdout.writeln('[Fim da Paginação] Nenhum exercício retornado no offset $offset.');
      break;
    }

    for (final raw in batch) {
      final item = Map<String, dynamic>.from(raw);
      final id = item['id'].toString();

      // Mapeia caminho local padronizado
      item['localGifPath'] = 'novas_imagens/$id.gif';

      // Garante URL de mídia válida (se a API omitir gifUrl no payload, usa o endpoint oficial de streaming)
      final rawGifUrl = item['gifUrl']?.toString().trim();
      if (rawGifUrl == null || rawGifUrl.isEmpty) {
        item['gifUrl'] = 'https://$apiHost/image?exerciseId=$id&resolution=360';
      }

      exercises.add(item);
    }

    offset += batch.length;

    // Se o lote recebido for menor que o limite, chegamos ao final
    if (batch.length < limit) {
      stdout.writeln('[Fim da Paginação] Último lote incompleto recebido (${batch.length} itens).');
      break;
    }

    // Delay de 250ms entre requisições de página
    await Future.delayed(const Duration(milliseconds: 250));
  }

  return exercises;
}

/// Executa a chamada da página com round-robin e recuperação contra rate limit / erros
Future<List<Map<String, dynamic>>?> _fetchPageWithRetry(
  http.Client client,
  ApiKeyManager keyManager,
  int offset,
  int limit,
) async {
  int attempts = 0;
  final int maxAttempts = keyManager.keys.length * 4;

  while (attempts < maxAttempts) {
    final keyNum = keyManager.keyNumber;
    final currentKey = keyManager.currentKey;
    final url = 'https://$apiHost/exercises?limit=$limit&offset=$offset';

    try {
      stdout.write('[Chave $keyNum] Consultando offset $offset... ');

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'x-rapidapi-key': currentKey,
          'x-rapidapi-host': apiHost,
        },
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<Map<String, dynamic>> items;
        if (decoded is List) {
          items = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } else {
          items = [];
        }

        stdout.writeln('(+${items.length} exercícios)');
        // Rotaciona chave para o próximo lote (round-robin)
        keyManager.rotate();
        return items;
      } else if (response.statusCode == 429 || response.statusCode == 403) {
        // Rate limit ou cota da chave
        stdout.writeln('[Rate Limit HTTP ${response.statusCode}] Alternando chave...');
        keyManager.rotate();
        attempts++;
        if (attempts % keyManager.keys.length == 0) {
          stdout.writeln('[Espera] Todas as chaves em limite. Aguardando 5s...');
          await Future.delayed(const Duration(seconds: 5));
        }
      } else if (response.statusCode >= 500) {
        // Erro de servidor temporário
        stdout.writeln('[Erro Servidor HTTP ${response.statusCode}] Alternando chave...');
        keyManager.rotate();
        attempts++;
        await Future.delayed(const Duration(seconds: 2));
      } else {
        stdout.writeln('[HTTP ${response.statusCode}] Alternando chave...');
        keyManager.rotate();
        attempts++;
      }
    } catch (e) {
      stdout.writeln('[Exceção de Conexão: $e] Alternando chave...');
      keyManager.rotate();
      attempts++;
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  throw Exception('Falha persistente ao consultar offset $offset após $attempts tentativas.');
}

/// Download sequencial de GIFs com idempotência, rotação e delays
Future<void> _downloadGifs(
  http.Client client,
  ApiKeyManager keyManager,
  Directory outputDir,
  List<Map<String, dynamic>> exercises,
) async {
  final total = exercises.length;
  int downloadedCount = 0;
  int skippedCount = 0;
  int errorCount = 0;

  for (int i = 0; i < total; i++) {
    final exercise = exercises[i];
    final id = exercise['id']?.toString() ?? 'unknown_${i + 1}';
    final name = exercise['name']?.toString() ?? 'sem_nome';
    final gifUrl = exercise['gifUrl']?.toString() ?? '';
    final indexLabel = '${i + 1}/$total';

    final targetFile = File('${outputDir.path}/$id.gif');

    // 1. Idempotência: verifica se o arquivo já existe e é válido
    if (targetFile.existsSync() && targetFile.lengthSync() > 0) {
      stdout.writeln('[$indexLabel] $id.gif já existe - $name... [PULADO]');
      skippedCount++;
      continue;
    }

    if (gifUrl.isEmpty) {
      stdout.writeln('[$indexLabel] $id.gif - $name... [SEM URL DE GIF]');
      errorCount++;
      continue;
    }

    // 2. Download do binário com rotação e tratamento de falhas
    stdout.write('[$indexLabel] Baixando $id.gif - $name... ');

    final success = await _downloadBinaryWithRetry(
      client,
      keyManager,
      gifUrl,
      targetFile,
    );

    if (success) {
      stdout.writeln('[OK]');
      downloadedCount++;
    } else {
      stdout.writeln('[FALHA]');
      errorCount++;
    }

    // Delay de 150ms a 200ms entre downloads para manter a conexão estável
    await Future.delayed(const Duration(milliseconds: 175));
  }

  stdout.writeln('\n[Resumo de Mídias]');
  stdout.writeln('  Novos downloads: $downloadedCount');
  stdout.writeln('  Pulados (já existentes): $skippedCount');
  stdout.writeln('  Falhas: $errorCount');
}

/// Baixa o binário de um GIF salvando primeiro em arquivo temporário (.tmp) para escrita atômica
Future<bool> _downloadBinaryWithRetry(
  http.Client client,
  ApiKeyManager keyManager,
  String url,
  File destinationFile,
) async {
  int attempts = 0;
  final int maxAttempts = keyManager.keys.length * 3;
  final tempFile = File('${destinationFile.path}.tmp');

  while (attempts < maxAttempts) {
    final headers = keyManager.getHeadersForUrl(url);

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        // Escrita atômica via arquivo temporário
        await tempFile.writeAsBytes(response.bodyBytes, flush: true);
        if (tempFile.existsSync()) {
          tempFile.renameSync(destinationFile.path);
        }

        // Rotaciona chave para distribuir a cota de download
        keyManager.rotate();
        return true;
      } else if (response.statusCode == 429 || response.statusCode == 403) {
        keyManager.rotate();
        attempts++;
        if (attempts % keyManager.keys.length == 0) {
          await Future.delayed(const Duration(seconds: 4));
        }
      } else {
        keyManager.rotate();
        attempts++;
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (_) {
      keyManager.rotate();
      attempts++;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // Remove arquivo temporário se sobrou de falhas
  if (tempFile.existsSync()) {
    try {
      tempFile.deleteSync();
    } catch (_) {}
  }

  return false;
}

/// Salva a lista de metadados em JSON formatado
Future<void> _saveMetadataJson(File file, List<Map<String, dynamic>> exercises) async {
  final encoder = const JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(exercises);
  await file.writeAsString(jsonString, flush: true);
}
