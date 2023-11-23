defmodule Sqlite3 do
  use DefC, compile: "-lsqlite3"

  defc(:test, 0, ~S"""
  #include<sqlite3.h>

  ERL_NIF_TERM raise(ErlNifEnv *env, char *reason) {
    return enif_raise_exception(env, enif_make_atom(env, reason));
  }

  static ERL_NIF_TERM test_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
  {
    sqlite3 *db;
    sqlite3_stmt *stmt;
    int r;

    r = sqlite3_open(":memory:", &db);
    if (r != SQLITE_OK) {
      fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db));
      sqlite3_close(db);
      return raise(env, "exit");
    }

    r = sqlite3_prepare_v2(db, "SELECT SQLITE_VERSION()", -1, &stmt, 0);    
    if (r != SQLITE_OK) {
      fprintf(stderr, "Failed to fetch data: %s\n", sqlite3_errmsg(db));
      sqlite3_close(db);
      return raise(env, "exit");
    }

    r = sqlite3_step(stmt);
    if (r == SQLITE_ROW) {
      printf("%s\n", sqlite3_column_text(stmt, 0));
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return enif_make_atom(env, "ok");
  }
  """)
end
