%% @author Paolo Oliveira <paolo@fisica.ufc.br>
%% @copyright 2015-2016 Paolo Oliveira (license MIT)
%% @version 1.0.0
%% @doc
%% A simple, pure erlang implementation of a module for <b>Raspberry Pi's General Purpose
%% Input/Output</b> (GPIO), using the standard Linux kernel interface for user-space, sysfs,
%% available at <b>/sys/class/gpio/</b>.
%% @end

-module(gpio).
-export([init/1, init/2, handler/2, read/1, write/2, stop/1]).
-author('Paolo Oliveira <paolo@fisica.ufc.br>').

%% API

% @doc: Initialize a Pin as input or output.
init(Pin, Direction) ->
  Ref = configure(Pin, Direction),
  Pid = spawn(?MODULE, handler, [Ref, Pin]),
  Pid.

% @doc: A shortcut to initialize a Pin as output.
init(Pin) ->
  init(Pin, out).

% @doc: Stop using and release the Pin referenced as file descriptor Ref.
stop(Ref) ->
  Ref ! stop,
  ok.

% @doc: Read from an initialized Pin referenced as the file descriptor Ref.
read(Ref) ->
  Ref ! {recv, self()},
  receive
    Msg ->
      Msg
  end.

% @doc: Write value Val to an initialized Pin referenced as the file descriptor Ref.
write(Ref, Val) ->
  Ref ! {send, Val},
  ok.

%% Internals

configure(Pin, Direction) ->
  DirectionFile = "/sys/class/gpio/gpio" ++ integer_to_list(Pin) ++ "/direction",

  % Export the GPIO pin
  {ok, RefExport} = file:open("/sys/class/gpio/export", [write]),
  file:write(RefExport, integer_to_list(Pin)),
  file:close(RefExport),

  % It can take a moment for the GPIO pin file to be created.
  case filelib:is_file(DirectionFile) of
      true -> ok;
      false -> receive after 1000 -> ok end
  end,

  {ok, RefDirection} = file:open(DirectionFile, [write]),
  case Direction of
    in -> file:write(RefDirection, "in");
    out -> file:write(RefDirection, "out")
  end,
  file:close(RefDirection),
  {ok, RefVal} = file:open("/sys/class/gpio/gpio" ++ integer_to_list(Pin) ++ "/value", [read, write]),
  RefVal.

release(Pin) ->
  {ok, RefUnexport} = file:open("/sys/class/gpio/unexport", [write]),
  file:write(RefUnexport, integer_to_list(Pin)),
  file:close(RefUnexport).

% @doc: Message passing interface, should not be used directly, it is present for debugging purpose.
handler(Ref, Pin) ->
  receive
    {send, Val} ->
      file:position(Ref, 0),
      file:write(Ref, integer_to_list(Val)),
      handler(Ref, Pin);
    {recv, From} ->
      file:position(Ref, 0),
      {ok, Data} = file:read(Ref, 1),
      From ! Data,
      handler(Ref, Pin);
    stop ->
      file:close(Ref),
      release(Pin),
      ok
   end.

%% End of Module.
