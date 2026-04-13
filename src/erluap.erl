-module(erluap).

-include("erluap.hrl").

-export([
    parse/1,
    parse_as_proplist/1,
    is_spider/1
]).

-type parse_error() :: {error, term()}.
-type parse_result() :: {device(), os(), browser()} | parse_error().
-type parse_as_proplist_result() ::
    [{device, list()} | {os, list()} | {browser, list()}] | parse_error().

-spec parse(binary() | iolist()) ->
    parse_result().

parse(UserAgent) ->
    erluap_nif:parse(UserAgent).

-spec parse_as_proplist(binary() | iolist()) ->
    parse_as_proplist_result().

parse_as_proplist(UserAgent) ->
    case erluap_nif:parse(UserAgent) of
        {Device, Os, Browser} ->
            [{device, rec2proplist(Device)}, {os, rec2proplist(Os)}, {browser, rec2proplist(Browser)}];
        Error ->
            Error
    end.

-spec is_spider(device()) ->
    boolean().

is_spider(#device{family = F}) ->
    F == <<"Spider">>.

% internals

-spec rec2proplist(device() | os() | browser()) ->
    list().

rec2proplist(#device{} = Rec) ->
    lists:zip(record_info(fields, device), tl(tuple_to_list(Rec)));
rec2proplist(#agent{} = Rec) ->
    lists:zip(record_info(fields, agent), tl(tuple_to_list(Rec))).
