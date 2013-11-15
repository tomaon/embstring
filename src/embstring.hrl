
-record(embstring, {
          to_encoding :: non_neg_integer(),   %% enum mbfl_no_encoding (mbfl_encodnig.h)
          from_encoding :: non_neg_integer(), %% enum mbfl_no_encondig (mbfl_encoding.h)
          language :: non_neg_integer()       %% enum mbfl_no_language (mbfl_language.h)
         }).

-type embstring() :: #embstring{}.
