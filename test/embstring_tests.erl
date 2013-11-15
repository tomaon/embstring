-module(embstring_tests).

-ifdef(TEST).

-import(embstring, [new/3, convert/2]).
-import(embstring, [name2encoding/1, is_support_encoding/1, convert_encoding/4]).

-include_lib("eunit/include/eunit.hrl").

suite_setup() ->
    new("UTF-8", "Shift_JIS", "Japanese").

suite_cleanup(_) ->
    ok.

suite_simple_test_() ->
    {setup,
     fun suite_setup/0,
     fun suite_cleanup/1,
     fun(R) ->
             [
              {"new/3",
               [
                ?_assertEqual({error, badarg}, new("UTF-8", "Shift_JIS", japanese)),
                ?_assertEqual({error, badarg}, new("UTF-8", shift_jis, "Japanese")),
                ?_assertEqual({error, badarg}, new(utf8, "Shift_JIS", "Japanese"))
               ]
              },
              {"convert/2",
               [
                ?_assertEqual("abc", convert("abc", R)),
                ?_assertEqual("文字", convert([149,182,142,154], R)),
                ?_assertEqual({error, badarg}, convert(true, R)),
                ?_assertEqual({error, badarg}, convert(0, R))
               ]
              },
              {"name2encoding/1",
               [
                ?_assertEqual([], name2encoding("invalid")),
                ?_assertEqual("UTF-8", name2encoding("UTF-8")),
                ?_assertEqual("UTF-8", name2encoding("utf-8")),
                ?_assertEqual("UTF-8", name2encoding("utf8")),
                ?_assertEqual({error, badarg}, name2encoding(true)),
                ?_assertEqual({error, badarg}, name2encoding(0)),
                ?_assertEqual({error, badarg}, name2encoding(-1))
               ]
              },
              {"is_support_encoding/1",
               [
                ?_assertEqual(true, is_support_encoding("UTF-8")),
                ?_assertEqual(true, is_support_encoding("Shift_JIS")),
                ?_assertEqual(true, is_support_encoding("EUC-JP")),
                ?_assertEqual(false, is_support_encoding("invalid")),
                ?_assertEqual({error, badarg}, is_support_encoding(true)),
                ?_assertEqual({error, badarg}, is_support_encoding(0))
               ]
              },
              {"convert_encoding/4",
               [
                ?_assertEqual("abc", convert_encoding("abc", "UTF-8", "UTF-8", "Japanese")),
                ?_assertEqual("abc", convert_encoding("abc", "EUC-JP", "UTF-8", "Japanese")),
                ?_assertEqual("abc", convert_encoding("abc", "Shift_JIS", "UTF-8", "Japanese")),
                ?_assertEqual("文字", convert_encoding([230,150,135,229,173,151], "UTF-8", "UTF-8", "Japanese")),
                ?_assertEqual([230,150,135,229,173,151], convert_encoding("文字", "UTF-8", "UTF-8", "Japanese")),
                ?_assertEqual([202,184,187,250], convert_encoding("文字", "EUC-JP", "UTF-8", "Japanese")),
                ?_assertEqual([149,182,142,154], convert_encoding("文字", "Shift_JIS", "UTF-8", "Japanese")),
                ?_assertEqual([230,150,135,229,173,151], convert_encoding([202,184,187,250], "UTF-8", "EUC-JP", "Japanese")),
                ?_assertEqual([230,150,135,229,173,151], convert_encoding([149,182,142,154], "UTF-8", "Shift_JIS", "Japanese")),
                ?_assertEqual({error, badarg}, convert_encoding(true, "UTF-8", "UTF-8", "Japanese")),
                ?_assertEqual({error, badarg}, convert_encoding(0, "UTF-8", "UTF-8", "Japanese"))
               ]
              }
             ]
     end
    }.

-endif.
