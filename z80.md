
# Prologue #
Erlang est un langage vraiment interessant mais clairement pas fait pour faire ce genre de programme.
Ne serait-ce que sur l'absence de variable mutable comme F# par exemple. Il en resulte un gaspillage de mémoire
impressionnant.
Pourquoi le Z80 ? déjà fait en C et pas essayé avec un langage fonctionnel.
Avec du recul Elixir présente une meilleure solution :)

# Source #
http://z80-heaven.wikidot.com/opcode-reference-chart
Zilog_Z80_Programmer's_Reference_Manual

# Status #
Un sacré bor***
Encore beaucoup beaucoup de chose à faire

# Fonctionnement #
c(z80).
z80:open().

```
a = 0   f = 0  b = 0  c = 0  d = 0  e = 0  h = 0  l = 0  ix = 0  iy = 0  pc = 2  sp = DFF0  val = 4         [0 0 - 0 - 0 0 0] INC B
a = 0   f = 0  b = 1  c = 0  d = 0  e = 0  h = 0  l = 0  ix = 0  iy = 0  pc = 3  sp = DFF0  val = 3E        [0 0 - 0 - 0 0 0] LD A,N
a = 60  f = 0  b = 1  c = 0  d = 0  e = 0  h = 0  l = 0  ix = 0  iy = 0  pc = 5  sp = DFF0  val = 3C        [0 0 - 0 - 0 0 0] ND*
a = 60  f = 0  b = 1  c = 0  d = 0  e = 0  h = 0  l = 0  ix = 0  iy = 0  pc = 6  sp = DFF0  val = 3D        [0 0 - 0 - 0 0 0] DEC A
a = 59  f = 0  b = 1  c = 0  d = 0  e = 0  h = 0  l = 0  ix = 0  iy = 0  pc = 7  sp = DFF0  val = 0         [0 0 - 0 - 0 1 0] NOP
a = 59  f = 0  b = 1  c = 0  d = 0  e = 0  h = 0  l = 0  ix = 0  iy = 0  pc = 8  sp = DFF0  val = 0         [0 0 - 0 - 0 1 0] NOP
```
