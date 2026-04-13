-module(erluap_nif).

-define(NOT_LOADED, not_loaded(?LINE)).
-define(REGEXES_FILE, <<"regexes.yaml">>).

-on_load(load_nif/0).

-export([
    parse/1
]).

%% NIF functions

load_nif() ->
    SoName = get_priv_path(?MODULE),
    Regexes = get_priv_path(?REGEXES_FILE),

    case filelib:file_size(Regexes) > 0 of
        true ->
            case erlang:load_nif(SoName, Regexes) of
                ok ->
                    ok;
                {error, {Reason, Text}} ->
                    {error, {failed_to_load_nif, SoName, Reason, Text}}
            end;
        false ->
            {error, {regex_file_not_available, Regexes}}
    end.

get_priv_path(File) ->
    filename:join(code:priv_dir(erluap), File).

not_loaded(Line) ->
    erlang:nif_error({not_loaded, [{module, ?MODULE}, {line, Line}]}).

parse(_UserAgent) ->
    ?NOT_LOADED.
