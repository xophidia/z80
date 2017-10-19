-module(z80).
-export([open/0, read/3, read/1, print/1, replacenth/3, replacenth/5, test/0]).
-export([calcR8/1,calcR16/3, read2bytes/1,inc/2, dec/2, convertSigned_Unsigned/2,isoverflow/1, isoverflow/2]).
-include("z80.hrl").
-vsn(0.1).
-author("Xophidia").

%% @author xophidia <xophidia@gmail.com>
%% [https://github.com/xophidia]
%% @version 0.1


%% @doc Open a file and read/execute all opcode

open() ->
  %{ok, Data} = file:read_file("/Users/xophidia/Downloads/Sonic.sms"),
  %ListB = binary_to_list(Data),
  ListB = [0,16#4,16#3E,60,16#3C,16#3D,0,0,0],
  read(#reg{data=ListB}).

%% @doc print all opcode

read(#reg{data=ListB} = Reg, Debut, Fin)->
  [io:format("offset ~p valeur ~p~n", [X, lists:nth(X,Reg#reg.data)]) || X <- lists:seq(Debut,Fin)].

%% @todo Write all opcode + H Flag
%% @main function, read and execute n opcodes

read(#reg{data=ListB} = Reg) when Reg#reg.pc < ?NB_INSTRUCTION ->
  %io:format("opcode ~p",[lists:nth(Reg#reg.pc,Data)]),
  Nreg = case lists:nth(Reg#reg.pc,Reg#reg.data) of
        16#0 -> io:format(" NOP~n"),
            Reg#reg{pc = Reg#reg.pc + 1};
        16#02 -> io:format(" LD (BC), A~n"),
            Reg#reg{pc = Reg#reg.pc + 1, data=replacenth(calcR16(bc, Reg#reg.b, Reg#reg.c), Reg#reg.a, Reg#reg.data)};
        16#03 -> io:format(" INC BC ~n"),
            Reg#reg{pc = Reg#reg.pc + 1, b = lists:nth(1, inc(bc, Reg)), c = lists:nth(2, inc(bc, Reg))};
        16#04 -> io:format(" INC B~n"),
            Reg#reg{pc = Reg#reg.pc + 1, b = Reg#reg.b + 1, flag = (Reg#reg.flag)#flag{
                s = case Reg#reg.b + 1 < 0 of true -> 1; false ->  0 end,
                z = case Reg#reg.b + 1 == 0 of true -> 1; false -> 0 end,
                n = 0,
                p = case Reg#reg.b == 127 of true -> 1; false -> 0 end}
              };
        16#05 -> io:format(" DEC B~n"),
              dec8(b, Reg);
        16#06 -> io:format(" LD B,N ~n"),
            Reg#reg{b = lists:nth(Reg#reg.pc+1,Reg#reg.data), pc = Reg#reg.pc + 2};
        16#0A -> io:format(" LD A,(BC) ~p ~n", [lists:nth(calcR16(bc, Reg#reg.b, Reg#reg.c), Reg#reg.data)]),
            Reg#reg{a = lists:nth(calcR16(bc, Reg#reg.b, Reg#reg.c), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#0C -> io:format(" INC C~n"),
            Reg#reg{pc = Reg#reg.pc + 1, c = Reg#reg.c + 1, flag = (Reg#reg.flag)#flag{
                s = case Reg#reg.c + 1 < 0 of true -> 1; false ->  0 end,
                z = case Reg#reg.c + 1 == 0 of true -> 1; false -> 0 end,
                n = 0,
                p = case Reg#reg.c == 127 of true -> 1; false -> 0 end}
              };
        16#D -> io:format(" DEC C~n"),
                  dec8(c, Reg);
        16#0E -> io:format(" LD C,N ~n"),
            Reg#reg{c = lists:nth(Reg#reg.pc+1,Reg#reg.data), pc = Reg#reg.pc + 2};
        16#12 -> io:format(" LD (DE), A~n"),
            Reg#reg{pc = Reg#reg.pc + 1, data=replacenth(calcR16(de, Reg#reg.d, Reg#reg.e), Reg#reg.a, Reg#reg.data)};

        16#14 -> io:format(" INC D~n"),
            Reg#reg{pc = Reg#reg.pc + 1, d = Reg#reg.d + 1, flag = (Reg#reg.flag)#flag{
                s = case Reg#reg.d + 1 < 0 of true -> 1; false ->  0 end, %% H detect carry from bit 3
                z = case Reg#reg.d + 1 == 0 of true -> 1; false -> 0 end,
                n = 0,
                p = case Reg#reg.d == 127 of true -> 1; false -> 0 end}
              };
        16#15 -> io:format(" DEC D~n"),
                  dec8(d, Reg);
        16#16 -> io:format(" LD D,N ~n"),
            Reg#reg{d = lists:nth(Reg#reg.pc+1,Reg#reg.data), pc = Reg#reg.pc + 2};
        16#1A -> io:format(" LD A,(DE) ~n"),
              Reg#reg{a = lists:nth(calcR16(de, Reg#reg.d, Reg#reg.e), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#1C -> io:format(" INC E~n"),
            Reg#reg{e = Reg#reg.e + 1, pc = Reg#reg.pc + 1};
        16#1D -> io:format(" DEC E~n"),
                  dec8(e, Reg);
        16#1E -> io:format(" LD E,N ~n"),
            Reg#reg{e = lists:nth(Reg#reg.pc+1,Reg#reg.data), pc = Reg#reg.pc + 2};
        16#20 -> io:format(" JR NZ, NN ~p ~p ~n", [lists:nth(Reg#reg.pc+1,Reg#reg.data), lists:nth(Reg#reg.pc+2,Reg#reg.data)]),
            case (Reg#reg.flag)#flag.z == 0 of
              true -> Reg#reg{pc = calcR16(nn, lists:nth(Reg#reg.pc+1,Reg#reg.data), lists:nth(Reg#reg.pc+2,Reg#reg.data))};
              false ->Reg#reg{pc = Reg#reg.pc + 1}
            end;
        16#24 -> io:format(" INC H~n"),
            Reg#reg{h = Reg#reg.h + 1 , pc = Reg#reg.pc + 1};
        16#25 -> io:format(" DEC H~n"),
            dec8(h, Reg);
        16#26 -> io:format(" LD H,N ~n"),
            Reg#reg{h = lists:nth(Reg#reg.pc+1,Reg#reg.data), pc = Reg#reg.pc + 2};
        16#25 -> io:format(" DEC L~n"),
            dec8(l, Reg);

        16#2E -> io:format(" LD L,N ~n"),
            Reg#reg{a = lists:nth(Reg#reg.pc+1,Reg#reg.data), pc = Reg#reg.pc + 2};
        16#32 -> io:format( "LD (nn), A ~n"),
            Reg#reg{pc = Reg#reg.pc + 1, data=replacenth(calcR16(nn, lists:nth(Reg#reg.pc+1,Reg#reg.data), lists:nth(Reg#reg.pc+2,Reg#reg.data)), Reg#reg.a, Reg#reg.data)};
        16#36 -> io:format(" LD (HL), N ~n"),
            Reg#reg{pc = Reg#reg.pc + 2, data=replacenth(calcR16(hl, Reg#reg.h, Reg#reg.l), lists:nth(Reg#reg.pc+1,Reg#reg.data), Reg#reg.data)};
        16#38 -> io:format(" JR C,e~n"),
              <<A:8/signed-integer>> = binary:encode_unsigned(lists:nth(Reg#reg.pc+1,Reg#reg.data)),
              Reg#reg{
                pc = case (Reg#reg.flag)#flag.c == 0 of
                  true -> 1;
                  false -> A
                end
                + Reg#reg.pc
              };
        16#3A -> io:format(" LD A, (nn) ~n"),
             Reg#reg{a = lists:nth(read2bytes(Reg), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#3D -> io:format(" DEC A~n"),
              dec8(a, Reg);
        16#3E -> io:format(" LD A,N ~n"),
            Reg#reg{a = lists:nth(Reg#reg.pc+1, Reg#reg.data), pc = Reg#reg.pc + 2};
        16#40 -> io:format(" LD B,B ~n"),
            Reg#reg{b = Reg#reg.b, pc = Reg#reg.pc + 1};
        16#41 -> io:format(" LD B,C ~n"),
            Reg#reg{b = Reg#reg.c, pc = Reg#reg.pc + 1};
        16#42 -> io:format(" LD B,D ~n"),
            Reg#reg{b = Reg#reg.d, pc = Reg#reg.pc + 1};
        16#43 -> io:format(" LD B,E ~n"),
            Reg#reg{b = Reg#reg.e, pc = Reg#reg.pc + 1};
        16#44 -> io:format(" LD B,H ~n"),
            Reg#reg{b = Reg#reg.h, pc = Reg#reg.pc + 1};
        16#45 -> io:format(" LD B,L ~n"),
            Reg#reg{b = Reg#reg.l, pc = Reg#reg.pc + 1};
        16#46 -> io:format(" LD B,(HL) ~n"),
            Reg#reg{b = lists:nth(calcR16(hl, Reg#reg.h, Reg#reg.l), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#4E -> io:format(" LD C,(HL) ~n"),
            Reg#reg{c = lists:nth(calcR16(hl, Reg#reg.h, Reg#reg.l), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#56 -> io:format(" LD D,(HL) ~n"),
            Reg#reg{d = lists:nth(calcR16(hl, #reg.h, Reg#reg.l), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#5E -> io:format(" LD E,(HL) ~n"),
            Reg#reg{e = lists:nth(calcR16(hl, Reg#reg.h, Reg#reg.l), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#61 -> io:format(" DEC A~n"),
                  dec8(a, Reg);
        16#66 -> io:format(" LD H,(HL) ~n"),
            Reg#reg{h = lists:nth(calcR16(hl, Reg#reg.h, Reg#reg.l), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#6E -> io:format(" LD L,(HL) ~n"),
            Reg#reg{l = lists:nth(calcR16(hl, Reg#reg.h, Reg#reg.l), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#7E -> io:format(" LD A,(HL) ~n"),
            Reg#reg{a = lists:nth(calcR16(hl, Reg#reg.h, Reg#reg.l), Reg#reg.data), pc = Reg#reg.pc + 1};
        16#80 -> io:format(" ADD A, B ~n"),
              Reg#reg{a = Reg#reg.a + Reg#reg.b, pc = Reg#reg.pc + 1};
        16#82 -> io:format(" ADD A, D ~n"),
            Reg#reg{a = Reg#reg.a + Reg#reg.d, pc = Reg#reg.pc + 1};
        16#B9 -> io:format(" CP C ~n"),
        Reg#reg{pc = Reg#reg.pc + 2, flag = (Reg#reg.flag)#flag{ % C (borrow) and H (borrow from bit 4) are missing
           z = case convertSigned_Unsigned(unsigned, Reg#reg.a - Reg#reg.c) == 0 of true -> 1; false ->  0 end,
           s = case convertSigned_Unsigned(signed, Reg#reg.a - Reg#reg.c) < 0 of true -> 1; false -> 0 end,
           p = isoverflow(Reg),
           c = case (Reg#reg.a < Reg#reg.c)  of true -> 1; false -> 0 end, %%borrow for sub carry for add
           n = 1}
           };
        16#C3 -> io:format(" Jmp NN ~n"),
            Reg#reg{pc = read2bytes(Reg)};
        16#DB -> io:format(" IN A,(N) ~n"),
            Reg#reg{a = lists:nth(Reg#reg.pc + 1, Reg#reg.data), pc = Reg#reg.pc + 2}; %A verifier le fonctionenemnt de cet opcode
        16#FE -> io:format(" CP X ~n"),
             Reg#reg{pc = Reg#reg.pc + 2, flag = (Reg#reg.flag)#flag{
                z = case lists:nth(Reg#reg.pc+1,Reg#reg.data) == Reg#reg.a of true -> 1; false ->  0 end,
                c = case lists:nth(Reg#reg.pc+1,Reg#reg.data) < Reg#reg.a of true -> 1; false -> 0 end}
                };
        _ -> io:format(" ND*~n"),
            Reg#reg{pc = Reg#reg.pc + 1}
  end,

  print(Nreg),
  read(Nreg);

read(#reg{} = Reg) when Reg#reg.pc >= ?NB_INSTRUCTION ->
  io:format("End").

read2bytes(#reg{} = Reg)->
  <<X:16>> = list_to_binary([lists:nth(Reg#reg.pc+2,Reg#reg.data),lists:nth(Reg#reg.pc+1,Reg#reg.data)]),
  X.

%% @doc transform 2 bytes in a short

calcR16(Registre, A, B ) ->
  case Registre of
    hl ->
      <<HL:16>> = erlang:iolist_to_binary([binary:encode_unsigned(A), binary:encode_unsigned(B)]),
      HL;
    bc ->
      <<BC:16>> = erlang:iolist_to_binary([binary:encode_unsigned(A), binary:encode_unsigned(B)]),
      BC;
    de ->
      <<DE:16>> = erlang:iolist_to_binary([binary:encode_unsigned(A), binary:encode_unsigned(B)]),
      DE;
    nn ->
      <<NN:16>> = erlang:iolist_to_binary([binary:encode_unsigned(A), binary:encode_unsigned(B)]),
      NN;
    _ ->
      {error, error}
  end.

calcR8(A) when A >= 256 ->
  <<H:8,L:8>> = binary:encode_unsigned(A),
  [H,L];
calcR8(A) ->
  <<L:8>> = binary:encode_unsigned(A),
  [0,L].

inc(Registre, #reg{} = Reg) ->
  case Registre of
    bc ->
      R = calcR8(calcR16(Registre, Reg#reg.b, Reg#reg.c) + 1),
      R;
    _ ->
      {error, error}
  end.

dec(Registre, #reg{} = Reg) ->
  case Registre of
    bc ->
      R = calcR8(calcR16(Registre, Reg#reg.b, Reg#reg.c) - 1),
      R;
    _ ->
      {error, error}
  end.

dec8(Registre, #reg{} = Reg) ->
  case Registre of
    b ->
        Reg#reg{pc = Reg#reg.pc + 1, b = Reg#reg.b - 1, flag = (Reg#reg.flag)#flag{
            s = case Reg#reg.b - 1 < 0 of true -> 1; false ->  0 end,
            z = case Reg#reg.b - 1 == 0 of true -> 1; false -> 0 end,
            n = 1,
            p = case Reg#reg.b == 128 of true -> 1; false -> 0 end}
          };
    c ->
        Reg#reg{pc = Reg#reg.pc + 1, c = Reg#reg.c - 1, flag = (Reg#reg.flag)#flag{
            s = case Reg#reg.c - 1 < 0 of true -> 1; false ->  0 end,
            z = case Reg#reg.c - 1 == 0 of true -> 1; false -> 0 end,
            n = 1,
            p = case Reg#reg.c == 128 of true -> 1; false -> 0 end}
          };
    d ->
        Reg#reg{pc = Reg#reg.pc + 1, d = Reg#reg.d - 1, flag = (Reg#reg.flag)#flag{
            s = case Reg#reg.d - 1 < 0 of true -> 1; false ->  0 end,
            z = case Reg#reg.d - 1 == 0 of true -> 1; false -> 0 end,
            n = 1,
            p = case Reg#reg.d == 128 of true -> 1; false -> 0 end}
          };
    e ->
        Reg#reg{pc = Reg#reg.pc + 1, c = Reg#reg.e - 1, flag = (Reg#reg.flag)#flag{
            s = case Reg#reg.e - 1 < 0 of true -> 1; false ->  0 end,
            z = case Reg#reg.e - 1 == 0 of true -> 1; false -> 0 end,
            n = 1,
            p = case Reg#reg.e == 128 of true -> 1; false -> 0 end}
          };
    h ->
        Reg#reg{pc = Reg#reg.pc + 1, h = Reg#reg.h - 1, flag = (Reg#reg.flag)#flag{
            s = case Reg#reg.h - 1 < 0 of true -> 1; false ->  0 end,
            z = case Reg#reg.h - 1 == 0 of true -> 1; false -> 0 end,
            n = 1,
            p = case Reg#reg.h == 128 of true -> 1; false -> 0 end}
          };
    l ->
        Reg#reg{pc = Reg#reg.pc + 1, l = Reg#reg.l - 1, flag = (Reg#reg.flag)#flag{
            s = case Reg#reg.l - 1 < 0 of true -> 1; false ->  0 end,
            z = case Reg#reg.l - 1 == 0 of true -> 1; false -> 0 end,
            n = 1,
            p = case Reg#reg.l == 128 of true -> 1; false -> 0 end}
          };
    a ->
        Reg#reg{pc = Reg#reg.pc + 1, a = Reg#reg.a - 1, flag = (Reg#reg.flag)#flag{
            s = case Reg#reg.a - 1 < 0 of true -> 1; false ->  0 end,
            z = case Reg#reg.a - 1 == 0 of true -> 1; false -> 0 end,
            n = 1,
            p = case Reg#reg.a == 128 of true -> 1; false -> 0 end}
          };
    _->  {error, error}
  end.

%% @doc Calc Unsigned / signed-integer
%% need to change this mess

convertSigned_Unsigned(Choice, A) ->
  case Choice of
    unsigned ->
      Y = lists:last(binary_to_list(term_to_binary({A}))),
      Y;
    signed ->
      <<Y:8/signed-integer>> = binary:encode_unsigned(lists:last(binary_to_list(term_to_binary({A})))),
      Y;
    _->
      {error, error}
  end.


%% @doc detect overflow
%% @todo : change to case b/c import local function fail with if

isoverflow(#reg{} = Reg) ->
  if
      (Reg#reg.a > 127 and (Reg#reg.c > 127)) and ((Reg#reg.a + Reg#reg.c) > 0)  -> 1;
      Reg#reg.a < 0 and (Reg#reg.c < 0) -> 1;
      true -> 0
  end.

isoverflow(A,B) ->
  if
      (A < 128) and (B < 128) and ((A + B) > 128)  -> 1;
     % (convertSigned_Unsigned(signed, A) > 128) and (convertSigned_Unsigned(signed, B) > 128) and (convertSigned_Unsigned(signed, A + B) < 128 ) -> 1;
      true -> 0
  end.
%% @doc Change value, use for (BC) ...

replacenth(Index,Value,List) ->
 replacenth(Index-1,Value,List,[],0).

replacenth(ReplaceIndex,Value,[_|List],Acc,ReplaceIndex) ->
 lists:reverse(Acc)++[Value|List];
replacenth(ReplaceIndex,Value,[V|List],Acc,Index) ->
 replacenth(ReplaceIndex,Value,List,[V|Acc],Index+1).

%% @doc main print function
%% used fo debug

print(#reg{} = Reg) ->
  io:format("a = ~p  f = ~p  b = ~p  c = ~p  d = ~p  e = ~p  h = ~p  l = ~p  ix = ~p  iy = ~p  pc = ~p  sp = ~.16B  val = ~.16B        [~p ~p - ~p - ~p ~p ~p]",
  [Reg#reg.a,Reg#reg.f,Reg#reg.b,Reg#reg.c, Reg#reg.d, Reg#reg.e, Reg#reg.h, Reg#reg.l, Reg#reg.ix, Reg#reg.iy,
  Reg#reg.pc, Reg#reg.sp, lists:nth(Reg#reg.pc,Reg#reg.data),
  (Reg#reg.flag)#flag.s, (Reg#reg.flag)#flag.z, (Reg#reg.flag)#flag.h, (Reg#reg.flag)#flag.p, (Reg#reg.flag)#flag.n, (Reg#reg.flag)#flag.c]).



test() ->
  1 = isoverflow(90,50),
  0 = isoverflow(90,20),
  ok.
