#πGPIO
A simple, pure erlang implementation of a module for Raspberry Pi's General Purpose 
Input/Output (GPIO), using the standard Linux kernel interface for user-space, sysfs,
available at /sys/class/gpio/.

This module was created to try robotics on raspberry Pi using erlang and have not tests,
error checking or fancy outputs. It was created for my own use and I'm releasing as it
may be useful for someone.<br>I hope you enjoy!

## Requirements
- **Raspbian** GNU/Linux;
- **erlang** 17+, `apt-get install erlang` solve it;
- **root**, to access "/sys/class/gpio/" files.
- **rebar**, to speed things up (`wget https://raw.github.com/wiki/rebar/rebar/rebar && chmod u+x rebar`)

## Usage
### on projects
- add to dependencies of your rebar.config:
```erlang
{deps, [
    {gpio, "", {git, "git://github.com/paoloo/gpio.git"}},
    ... % other dependencies goes here
]}.
```
- then just compile:
```
$ rebar compile
```

### on REPL
```erlang-repl
$ sudo erl
Erlang/OTP 17 [erts-6.2] [source] [async-threads:10] [kernel-poll:false]

Eshell V6.2  (abort with ^G)
1> c(gpio).
{ok,gpio}
2> L0 = gpio:init(23, out).
<0.43.0>
3> L1 = gpio:init(22, in).
<0.48.0>
4> gpio:write(L0, 1).
ok
5> gpio:read(L1).
"1"
```

## Documentation
- **init(Pin, Direction)** Initialize a **pin** as *output* or *input*, according to **Direction**(an atom). It returns a *Reference* to *Pin*.
- **init(Pin)** A shortcut to initialize *pin* as *output*. It, also, returns a *Reference* to *Pin*.
- **stop(Ref)** Stop using and release th **pin** referenced as **Ref**. It returns an atom, **ok**.
- **write(Ref, Val)** Writes **Val**, 1 or 0, into the **pin** initialized and referenced as **Ref**.
- **read(Ref)** Reads a value(1 or 0) from **pin** referenced as **Ref** and returns it.

For the official erlang-style documentation, run:
```
$ erl -noshell -run edoc_run application 'gpio' '"."' '[]'
```

## Tested on
- Erlang/OTP 17 erts-6.2 in GNU/Linux Raspian 8.0 (jessie) kernel 4.1.19+ armv61 on Raspberry B+
- Erlang R15B01 erts-5.9.1 in GNU/Linux Raspian 7 (wheezy) kernel 4.1.13+ armv6l on Raspberry B.

## License
[MIT License](LICENSE.md) © 2015-2016 Paolo Oliveira.
