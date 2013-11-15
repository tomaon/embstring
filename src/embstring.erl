-module(embstring).

-export([new/3, convert/2]).
-export([name2encoding/1, is_support_encoding/1, convert_encoding/4, version/0]).

-export([on_load/0]). % for dialyzer

-include("embstring.hrl").

%% == init ==

-on_load(on_load/0).

-spec on_load() -> ok|{error,_}.
on_load() ->
    Path = filename:join([priv_dir(), nif_file()]),
    LoadInfo = [],
    erlang:load_nif(Path, LoadInfo).

%% == public ==

-spec new(string(),string(),string()) -> embstring()|{error,_}.
new(ToEncoding, FromEncoding, Language)
  when is_list(ToEncoding), is_list(FromEncoding), is_list(Language) ->
    T = name2no_encoding_nif(ToEncoding),
    F = name2no_encoding_nif(FromEncoding),
    L = name2no_language_nif(Language),
    new3(T, F, L);
new(_, _, _) ->
    {error, badarg}.

-spec convert(string(),embstring()) -> string()|{error,_}.
convert(Str, #embstring{to_encoding=T,from_encoding=F,language=L})
  when is_list(Str) ->
    convert_encoding4(Str, T, F, L);
convert(_, _) ->
    {error, badarg}.

-spec name2encoding(string()) -> string()|{error,_}.
name2encoding(Encoding)
  when is_list(Encoding) ->
    name2encoding_nif(Encoding);
name2encoding(_) ->
    {error, badarg}.

-spec is_support_encoding(string()) -> boolean()|{error,badarg}.
is_support_encoding(Encoding)
  when is_list(Encoding) ->
    case name2no_encoding_nif(Encoding) of
        No when is_integer(No),0 =< No -> true;
        _ -> false
    end;
is_support_encoding(_) ->
    {error, badarg}.

-spec convert_encoding(string(),string(),string(),string()) -> string()|{error,_}.
convert_encoding(Str, ToEncoding, FromEncoding, Language)
  when is_list(Str), is_list(ToEncoding), is_list(FromEncoding), is_list(Language) ->
    T = name2no_encoding_nif(ToEncoding),
    F = name2no_encoding_nif(FromEncoding),
    L = name2no_language_nif(Language),
    convert_encoding4(Str, T, F, L);
convert_encoding(_, _, _, _) ->
    {error, badarg}.

-spec version() -> {version,{term(),term(),term()}}.
version() ->
    version_nif().

%% == private ==

new3(ToEncoding, FromEncoding, Language)
  when 0 =< ToEncoding, 0 =< FromEncoding, 0 =< Language ->
    #embstring{to_encoding = ToEncoding, from_encoding = FromEncoding, language = Language};
new3(_, _, _) ->
    {error, badarg}.

convert_encoding4(Str, ToEncoding, FromEncoding, Language)
  when is_list(Str), 0 =< ToEncoding, 0 =< FromEncoding, 0 =< Language ->
    convert_encoding_nif(Str, ToEncoding, FromEncoding, Language);
convert_encoding4(_, _, _, _) ->
    {error, badarg}.

priv_dir() ->
    lib_dir(?MODULE, priv).

nif_file() ->
    filename:join("lib", ?MODULE_STRING ++ "_drv").

lib_dir(Application, SubDir) ->
    case code:lib_dir(Application, SubDir) of
        {error, bad_name} ->
            {ok, Dir} = file:get_cwd(),
            filename:join(Dir, atom_to_list(SubDir));
        Dir ->
            Dir
    end.

%% == private: nif ==

name2encoding_nif(Name) when is_list(Name) -> "unknown";
name2encoding_nif(_) -> {error, badarg}.

name2no_encoding_nif(Name) when is_list(Name) -> 0;
name2no_encoding_nif(_) -> -1.

name2no_language_nif(Name) when is_list(Name) -> 0;
name2no_language_nif(_) -> -1.

convert_encoding_nif(Str, ToEncoding, FromEncoding, Language)
  when is_list(Str), 0 =< ToEncoding, 0 =< FromEncoding, 0 =< Language -> Str;
convert_encoding_nif(_, _, _, _) -> {error, badarg}.

version_nif() -> {version, {0,0,0}}.
