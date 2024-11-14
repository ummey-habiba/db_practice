import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {

  DbHelper._();

  static final getInstance = DbHelper._();

  static final String Table_Note='note';
  static final String Column_Note_Sno='s_no';
  static final String Column_Note_Title='title';
  static final String Column_Note_Desc='Desc';

  Database? myDB;

  Future<Database> getDB()async => myDB??= await openDB();

  Future<Database> openDB()async {
    Directory appDir =await  getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, 'noteDB.db');
    return await openDatabase(dbPath,onCreate: (db, version) {
db.execute('create table $Table_Note ($Column_Note_Sno integer primary key autoincrement,$Column_Note_Title text,$Column_Note_Desc text)');
    },version: 1);

  }
Future<bool>addNote({required String mTitle, required String mDesc})async{
    var db = await getDB();

   int rowsEffected=await db.insert(Table_Note, {
      Column_Note_Title : mTitle,
      Column_Note_Desc : mDesc,
    });
   return rowsEffected> 0;
}

  Future<bool>updateNote({required String mTitle, required String mDesc, required int sno})async{
    var db = await getDB();

    int rowsEffected=await db.update(Table_Note, {
      Column_Note_Title : mTitle,
      Column_Note_Desc : mDesc,
    },where: "$Column_Note_Sno= $sno" );
    return rowsEffected> 0;
  }

  Future<bool> deleteNote({required int sno})async {
     var db = await getDB();
     int rowsEffected = await db.delete(Table_Note,where: '$Column_Note_Sno= ?',whereArgs: ['$sno']);
     return rowsEffected>0;
  }

Future<List<Map<String,dynamic>>> getAllNotes()async{
    var db = await getDB();
   List<Map<String,dynamic>> mData = await db.query(Table_Note);
   return mData;
}

}