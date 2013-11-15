/*
 * embstring : wapper for libmbfl
 */

#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "erl_nif.h"

#include "mbfl/mbfilter.h"
#include "mbfl/mbfl_encoding.h"
#include "mbfl/mbfl_language.h"

// ------------------------------------
// ------------------------------------

typedef struct {
} embstring_t;

typedef unsigned char uchar_t;

// ------------------------------------
// ------------------------------------

static embstring_t *setup(ErlNifEnv *env, ERL_NIF_TERM load_info, embstring_t *p __attribute__((unused))) {
  assert(env), assert(enif_is_list(env, load_info));
  return (embstring_t *) enif_alloc(sizeof(embstring_t));
}

static ERL_NIF_TERM char2list(ErlNifEnv *env, const uchar_t buf[], size_t size) {

  ERL_NIF_TERM array[size];
  size_t n;

  for (n = 0; n < size; n++) {
    array[n] = enif_make_int(env, (int) buf[n]);
  }

  return enif_make_list_from_array(env, array, size);
}

static uchar_t *list2char(ErlNifEnv *env, ERL_NIF_TERM list, uchar_t buf[], size_t size) {

  ERL_NIF_TERM head, tail;
  int cell;
  size_t m, n;

  for (m = size-1, n = 0; n < m && enif_get_list_cell(env, list, &head, &tail); list = tail) {
    cell = 0;
    if (enif_get_int(env, head, &cell)) {
      buf[n++] = (uchar_t) cell;
    }
  }
  buf[n] = '\0';

  return buf;
}

static unsigned get_list_length(ErlNifEnv *env, ERL_NIF_TERM list) {

  unsigned len = 0;

  return enif_get_list_length(env, list, &len) ? len : 0;
}

// ------------------------------------
// ------------------------------------

static ERL_NIF_TERM name2encoding(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {

  ERL_NIF_TERM name;

  if (1 != argc) {
    return enif_make_badarg(env);
  }
  if (!enif_is_list(env, name = argv[0])) {
    return enif_make_badarg(env);
  }

  size_t size = get_list_length(env, name);
  uchar_t buf[size+1];

  const mbfl_encoding *encoding =
    mbfl_name2encoding((char *) list2char(env, name, buf, sizeof(buf)));

  const char *encoding_name = NULL != encoding ? encoding->name : "";

  return char2list(env, (const uchar_t *) encoding_name, strlen(encoding_name));
}

/*
  static ERL_NIF_TERM no2encoding(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {

  int no_encoding;

  if (1 != argc) {
  return enif_make_badarg(env);
  }
  if (!enif_get_int(env, argv[0], &no_encoding)) {
  return enif_make_badarg(env);
  }

  const mbfl_encoding *encoding = mbfl_no2encoding((enum mbfl_no_encoding) no_encoding);

  const char *encoding_name = NULL != encoding ? encoding->name : "";

  return char2list(env, (const uchar_t *) encoding_name, strlen(encoding_name));
  }
*/

static ERL_NIF_TERM name2no_encoding(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {

  ERL_NIF_TERM name;

  if (1 != argc) {
    return enif_make_badarg(env);
  }
  if (!enif_is_list(env, name = argv[0])) {
    return enif_make_badarg(env);
  }

  size_t size = get_list_length(env, name);
  uchar_t buf[size+1];

  enum mbfl_no_encoding no =
    mbfl_name2no_encoding((char *) list2char(env, name, buf, sizeof(buf)));

  return enif_make_int(env, no);
}

static ERL_NIF_TERM name2no_language(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {

  ERL_NIF_TERM name;

  if (1 != argc) {
    return enif_make_badarg(env);
  }
  if (!enif_is_list(env, name = argv[0])) {
    return enif_make_badarg(env);
  }

  size_t size = get_list_length(env, name);
  uchar_t buf[size+1];

  enum mbfl_no_language no =
    mbfl_name2no_language((char *) list2char(env, name, buf, sizeof(buf)));

  return enif_make_int(env, no);
}

static ERL_NIF_TERM convert_encoding(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {

  ERL_NIF_TERM str;
  int to_encoding, from_encoding, language;

  if (4 != argc) {
    return enif_make_badarg(env);
  }
  if (!enif_is_list(env, str = argv[0])) {
    return enif_make_badarg(env);
  }
  if (!enif_get_int(env, argv[1], &to_encoding)) {
    return enif_make_badarg(env);
  }
  if (!enif_get_int(env, argv[2], &from_encoding)) {
    return enif_make_badarg(env);
  }
  if (!enif_get_int(env, argv[3], &language)) {
    return enif_make_badarg(env);
  }

  size_t size = get_list_length(env, str);
  uchar_t buf[size+1];
  mbfl_string before, after, *result;

  mbfl_string_init(&before);
  mbfl_string_init(&after);

  before.no_encoding = from_encoding;
  before.no_language = language;
  before.val = list2char(env, str, buf, sizeof(buf));
  before.len = size;

  mbfl_buffer_converter *converter =
    mbfl_buffer_converter_new(from_encoding, to_encoding, 0);

  result = mbfl_buffer_converter_feed_result(converter, &before, &after);

  mbfl_buffer_converter_delete(converter);

  return char2list(env, result->val, result->len);
}

static ERL_NIF_TERM version(ErlNifEnv *env, int argc, const ERL_NIF_TERM *argv) {

  if (0 != argc) {
    return enif_make_badarg(env);
  }
  if (!enif_is_empty_list (env, argv[0])) { // dummy
  }

  ERL_NIF_TERM version;
  if(!enif_make_existing_atom(env, "version", &version, ERL_NIF_LATIN1)) {
    version = enif_make_atom(env, "version");
  }

  ERL_NIF_TERM major = enif_make_int(env, (int) MBFL_VERSION_MAJOR);
  ERL_NIF_TERM minor = enif_make_int(env, (int) MBFL_VERSION_MINOR);
  ERL_NIF_TERM teeny = enif_make_int(env, (int) MBFL_VERSION_TEENY);
  ERL_NIF_TERM tuple = enif_make_tuple3(env, major, minor, teeny);

  return enif_make_tuple2(env, version, tuple);
}

// ------------------------------------
// ------------------------------------

static ErlNifFunc nif_funcs[] = {
  {"name2encoding_nif", 1, name2encoding},
  {"name2no_encoding_nif", 1, name2no_encoding},
  {"name2no_language_nif", 1, name2no_language},
  {"convert_encoding_nif", 4, convert_encoding},
  {"version_nif", 0, version}
};

static int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  assert(env), assert(!(*priv_data)), assert(enif_is_list(env, load_info));
  *priv_data = (void *) setup(env, load_info, NULL);
  return NULL != *priv_data ? 0 : -1;
}

static int reload(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  assert(env), assert(*priv_data), assert(enif_is_list(env, load_info));
  *priv_data = (void *) setup(env, load_info, *priv_data);
  return NULL != *priv_data ? 0 : -1;
}

static int upgrade(ErlNifEnv *env, void **priv_data, void **old_priv_data, ERL_NIF_TERM load_info) {
  assert(env), assert(!(*priv_data)), assert(*old_priv_data), assert(enif_is_list(env, load_info));
  *priv_data = (void *) setup(env, load_info, *old_priv_data);
  return NULL != *priv_data ? 0 : -1;
}

static void unload(ErlNifEnv *env, void *priv_data) {
  assert(env), assert(priv_data);
  enif_free(priv_data);
}

ERL_NIF_INIT(embstring, nif_funcs, load, reload, upgrade, unload)
