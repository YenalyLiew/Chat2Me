import 'dart:developer';

import 'package:chat_to_me/logic/model/chat_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/chat_message.dart';

const _databaseName = "chat_history.db";

Future<int?> saveChatMessagesInDatabase(
    {required ChatMessages chatMessages, DateTime? dateTime, int? id}) async {
  final first = chatMessages.firstUserMessage;
  if (first == null) {
    return id;
  }
  final chatHistory = ChatHistory(
    id: id,
    content: first,
    dateTime: dateTime ?? DateTime.timestamp(),
  );
  log("Chat messages have been saved.", name: "ChatHistory");
  if (id == null) {
    return await BaseChatHistoryDatabase.singleton()
        .insertChat(chatHistory, chatMessages.allForDatabase);
  }
  return await BaseChatHistoryDatabase.singleton()
      .updateChatToFirst(id, chatHistory, chatMessages.allForDatabase);
}

class BaseChatHistoryDatabase {
  static const tableName = "ChatHistories";
  static const detailedTableName = "DetailedChatHistory";

  static BaseChatHistoryDatabase? _baseChatHistoryDatabase;

  factory BaseChatHistoryDatabase.singleton() =>
      _baseChatHistoryDatabase ??= BaseChatHistoryDatabase._();

  Database? _database;
  late Future<Database> _databaseFuture;
  late ChatHistoryDatabase chats;
  late DetailedChatHistoryDatabase detailed;

  static Future<void> initialize() async {
    final db = BaseChatHistoryDatabase.singleton();
    db._database = await (db._databaseFuture = db._getChatHistoryDatabase());
  }

  BaseChatHistoryDatabase._() {
    _databaseFuture = _getChatHistoryDatabase();
    detailed = DetailedChatHistoryDatabase._withDatabase(_databaseFuture);
    chats = ChatHistoryDatabase._withDatabase(_databaseFuture);
  }

  Future<Database> _getChatHistoryDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    return openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            dateTime INTEGER NOT NULL
          )
      """);
        await db.execute("""
          CREATE TABLE $detailedTableName(
            id INTEGER NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            dateTime INTEGER NOT NULL
          )
        """);
      },
      version: 1,
    );
  }

  Future<int> insertChat(
    ChatHistory chatHistory,
    List<DetailedChatHistory> detailedChatHistoryList,
  ) async {
    final db = _database ?? await _databaseFuture;
    final id = await chats._insert(chatHistory, db);
    for (final detailedChatHistory in detailedChatHistoryList) {
      detailedChatHistory.id = id; // IMPORTANT!
      await detailed._insert(detailedChatHistory, db);
    }
    return id;
  }

  Future<int> updateChatToFirst(
    int id,
    ChatHistory chatHistory,
    List<DetailedChatHistory> detailedChatHistoryList,
  ) async {
    final db = _database ?? await _databaseFuture;
    final newId = await chats._updateToFirst(id, chatHistory, db);
    await detailed._updateToFirst(newId, detailedChatHistoryList, db);
    return newId;
  }

  Future<int> deleteChatById(int id) async {
    final db = _database ?? await _databaseFuture;
    await chats._deleteById(id, db);
    await detailed._deleteById(id, db);
    return id;
  }

  Future<({int rows, int dRows})> deleteAllChat() async {
    final db = _database ?? await _databaseFuture;
    final rows = await chats._deleteAll(db);
    final dRows = await detailed._deleteAll(db);
    return (rows: rows, dRows: dRows);
  }
}

class ChatHistoryDatabase {
  final Future<Database> _databaseFuture;

  const ChatHistoryDatabase._withDatabase(this._databaseFuture);

  Future<int> _insert(ChatHistory chatHistory, [Database? database]) async {
    final db = database ?? await _databaseFuture;
    final id = await db.insert(
      BaseChatHistoryDatabase.tableName,
      chatHistory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> _updateToFirst(int id, ChatHistory chatHistory,
      [Database? database]) async {
    final db = database ?? await _databaseFuture;
    await _deleteById(id);
    final newId = await db.insert(
      BaseChatHistoryDatabase.tableName,
      chatHistory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return newId;
  }

  Future<int> _deleteById(int id, [Database? database]) async {
    final db = database ?? await _databaseFuture;
    return await db.delete(
      BaseChatHistoryDatabase.tableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> _deleteAll([Database? database]) async {
    final db = database ?? await _databaseFuture;
    return await db.delete(BaseChatHistoryDatabase.tableName);
  }

  Future<List<ChatHistory>> get allChatHistory async {
    final db = await _databaseFuture;
    final list =
        await db.query(BaseChatHistoryDatabase.tableName, orderBy: "id DESC");
    return list.map((e) => ChatHistory.fromMap(e)).toList();
  }
}

class DetailedChatHistoryDatabase {
  final Future<Database> _databaseFuture;

  const DetailedChatHistoryDatabase._withDatabase(this._databaseFuture);

  Future<int> _insert(DetailedChatHistory detailedChatHistory,
      [Database? database]) async {
    final db = database ?? await _databaseFuture;
    return await db.insert(
      BaseChatHistoryDatabase.detailedTableName,
      detailedChatHistory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> _updateToFirst(
      int newId, List<DetailedChatHistory> detailedChatHistoryList,
      [Database? database]) async {
    final db = database ?? await _databaseFuture;
    await _deleteById(newId, db);
    for (final detailedChatHistory in detailedChatHistoryList) {
      detailedChatHistory.id = newId; // IMPORTANT!
      _insert(detailedChatHistory, db);
    }
    return newId;
  }

  Future<int> _deleteById(int id, [Database? database]) async {
    final db = database ?? await _databaseFuture;
    return await db.delete(
      BaseChatHistoryDatabase.detailedTableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> _deleteAll([Database? database]) async {
    final db = database ?? await _databaseFuture;
    return await db.delete(BaseChatHistoryDatabase.detailedTableName);
  }

  Future<List<DetailedChatHistory>> load(int id) async {
    final db = await _databaseFuture;
    final query = await db.query(
      BaseChatHistoryDatabase.detailedTableName,
      where: "id = ?",
      whereArgs: [id],
      orderBy: "id",
    );
    return query.map((e) => DetailedChatHistory.fromMap(e)).toList();
  }
}
